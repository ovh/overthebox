# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
# pylint: disable=protected-access
"""OTBv2 Switch module, extension for VLANs

This module adds methods to the class Sw, all related to VLAN management
"""

import logging
from swconfig_otb.config import PORT_MIN, PORT_MAX, DEFAULT_VLAN
from swconfig_otb.sw_state import _States

logger = logging.getLogger('swconfig')

def _create_vid(self, vid):
    try:
        _, comments = self.send_cmd('vlan %d' % (vid), assert_state=_States.CONFIG_VLAN)
    except self.StateAssertionError:
        # The switch didn't even transition to config-vlan state. VLAN creation unsuccessful...
        logger.error("VLAN %d could not be created", vid)
        raise

    self.send_cmd('exit', assert_state=_States.CONFIG)

    if not any("VLAN %d is added" % (vid) in c for c in comments):
        logger.warning("VLAN %d already existed when asking the switch to create it", vid)

def _delete_vid(self, vid):
    out, comments = self.send_cmd('no vlan %d' % (vid))

    # Check whether deletion was forbidden because of voice VLAN
    if any("VLAN %d: Voice VLAN Can not be allowed to delete" % (vid) in l for l in out):
        logger.warning("VLAN %d is a voice VLAN so we were not allowed to remove it.", vid)
        logger.warning("Shooting voice VLAN %d to allow VLAN deletion anyway...", vid)
        self.send_cmd("no voice-vlan vlan")
        out, comments = self.send_cmd('no vlan %d' % (vid))

    # Check whether deletion failed because of already inexistent VLAN
    # Don't consider this to be an error, but log a warning as this is abnormal
    if any("VLAN %d: VLAN does not exist" % (vid) in l for l in out):
        logger.warning("VLAN %d was already inexistent when asking the switch to remove it", vid)
        return True

    # If we didn't get the switch confirmation, consider this is an error
    if not any("VLAN %d is removed" % (vid) in c for c in comments):
        logger.error("Didn't get switch confirmation when deleting VLAN %d", vid)
        return False

    # We got the confirmation :)
    return True

def update_vlan_conf(self, vlans_new, ports_new):
    logger.info("Gathering VLAN facts...")
    vlans_old, ports_old = self._parse_vlans()

    logger.debug("Wanted VLANs: %s", vlans_new)
    logger.debug("Current VLANs: %s", vlans_old)
    logger.debug("Wanted interfaces configuration %s", ports_new)
    logger.debug("Current interfaces configuration %s", ports_old)

    vlan_added, vlan_removed = self._set_diff(vlans_old, vlans_new)
    logger.debug("VIDs to be added: %s", vlan_added)
    logger.debug("VIDs to be removed: %s", vlan_removed)

    ports_changed = self._dict_diff(ports_old, ports_new)
    logger.debug("IFs to be updated: %s", ports_changed)

    if not ports_changed and not vlan_added and not vlan_removed:
        logger.info("Switch VLAN conf is the same as wanted conf. Nothing to do. :)")
        return

    # Browse each interface that we need to change
    # Compute what need to be done for each interface
    # At the same time group interfaces by "same changes that need to be done"
    if_actions = {}
    for port_id, vids in ((port_id, ports_new[port_id]) for port_id in ports_changed):
        mode = 'trunk' if vids['tagged'] else 'access'
        untagged = vids['untagged'] if vids['untagged'] else DEFAULT_VLAN

        if mode == 'trunk':
            # Compute the tagged VIDs we need to remove / add for this interface
            ifv_added, ifv_removed = self._set_diff(ports_old[port_id]['tagged'], vids['tagged'])
            # Convert the VID we want to remove / add to a VID range (ex: 1-7,8,100)
            tagged_removed = self._integer_set_to_string_range(ifv_removed)
            tagged_added = self._integer_set_to_string_range(ifv_added)

        # If the mode is 'access', we don't care what tagged VIDs need to be removed/added
        # Setting an interface mode to access will already discard all tagged VIDs...
        # So we set both to empty strings, this increases the grouping ratio for access mode ifs :)
        else:
            tagged_removed = tagged_added = ''

        # Construct our key, a tuple representing the actions to do for the interface
        # It can be inserted into a dict as key since it's hashable
        key = (mode, untagged, tagged_removed, tagged_added)

        # If this tuple of actions does not exist yet, create it as a new key to our dict
        # Then, assign to this key the value "empty set", and return this set
        # If it exists, just return the set
        # Then, whether the key existed or not, append to the interfaces set the current if
        # That way, we group interfaces by "same actions needed to be done"
        if_actions.setdefault(key, set()).add(port_id)

    logger.debug("Actions needed to be done on interfaces: %s", if_actions)

    # We know what needs to be done. Let's make the switch obeeeyyyyy! :p
    self._goto_admin_main_prompt()
    self.send_cmd('config', assert_state=_States.CONFIG)

    # Create VLAN that didn't exist before but should do now
    for vlan in vlan_added:
        logger.info('Creating VLAN %d', vlan)
        try:
            self._create_vid(vlan)
        except self.StateAssertionError:
            raise self.VlanError("An error occurred when creating VID %d", vlan)

    # Execute the actions we computed before for each interface range
    for actions, ifs in if_actions.iteritems():
        if_range = self._integer_set_to_string_range(ifs)

        logger.info("Configuring if range %s", if_range)
        self.send_cmd('interface range GigabitEthernet %s' % (if_range),
                      assert_state=_States.CONFIG_IF_RANGE)

        mode, untagged, tagged_removed, tagged_added = actions

        logger.info(" Setting mode into %s mode", mode)
        self.send_cmd('switchport mode %s' % (mode))

        if mode == 'trunk':
            logger.info(" Setting native VID to %d", untagged)
            self.send_cmd('switchport trunk native vlan %d' % (untagged))

            if tagged_removed:
                logger.info(' Removing obsolete VIDs %s', tagged_removed)
                self.send_cmd('switchport trunk allowed vlan remove %s' % (tagged_removed))

            if tagged_added:
                logger.info(' Adding new VIDs %s', tagged_added)
                self.send_cmd('switchport trunk allowed vlan add %s' % (tagged_added))
        else:
            logger.info(" Setting VID to %d", untagged)
            self.send_cmd('switchport access vlan %d' % (untagged))

        self.send_cmd('exit', assert_state=_States.CONFIG)

    # Delete VLAN that shouldn't exist any more
    for vlan in vlan_removed:
        logger.info('Deleting VLAN %d', vlan)
        if not self._delete_vid(vlan):
            raise self.VlanError("An error occurred when deleting VID %d", vlan)

    self.send_cmd('end', assert_state=_States.ADMIN_MAIN)

def _parse_vlans(self):
    """Ask the switch its VLAN state and return it

    Returns:
        A set and a dictionary of dictionary.
        - The set just contains all the existing VIDs on the switch.
        - For the dict: first dict layer has the interface number as key.
            The second layer has two keys: 'untagged' and 'tagged'.
                Key 'untagged': the value is either None or only one VID value
                Key 'tagged': the value is a set of VID this interface belongs to
    """
    out, _ = self.send_cmd("show vlan static")

    # Initialize our two return values
    vlans, ports = self.init_vlan_config_datastruct()

    # Skip header and the second line (-----+-----...)
    for line in out[2:]:
        row = [r.strip() for r in line.split('|')]
        vid, untagged, tagged = int(row[0]), row[2], row[3]

        vlans.add(vid)

        untagged_range = self._if_str_to_integer_set(untagged)
        tagged_range = self._if_str_to_integer_set(tagged)

        for if_ in untagged_range:
            if ports[if_]['untagged'] is None:
                ports[if_]['untagged'] = vid
            else:
                logger.warning("Skipping subsequent untagged VIDs for port %d. " \
                               "Value was %s", if_, ports[if_]['untagged'])

        for if_ in tagged_range:
            ports[if_]['tagged'].add(vid)

    return vlans, ports

@staticmethod
def init_vlan_config_datastruct():
    """Initialize an empty vlan config data structure"""
    vlans = set()
    ports = {key: {'untagged': None, 'tagged': set()} for key in range(PORT_MIN, PORT_MAX + 1)}

    return vlans, ports

@staticmethod
def _if_str_to_integer_set(string):
    """Take an interface range string and generate the expanded version in a set.

    Only the interface ranges starting with 'gi' will be taken into account.

    Args:
        string: A interface range string (ex 'gi4,gi6,gi8-10,gi16-18,lag2')

    Returns:
        A set of numbers which is the expansion of the whole range. For example,
            the above input will give set([4, 6, 8, 9, 10, 16, 17, 18])
    """
    # Split the string by ','.
    # Exclude elements that don't start with "gi" (we could have 'lag8-15', or '---').
    # Then, remove the 'gi' prefix and split by '-'. We end up with a list of lists.
    # This is a list of the ranges bounds (1 element or 2: start and end bounds).
    # Then, return a list of all the concatenated expanded ranges.
    # The trick of using a[0] and a[-1] allows it to work with single numbers as well.
    # This wouldn't be the case if we had used a[0] and a[1].
    # If there's only one digit [1], it will compute range(1, 1 + 1) which is 1.
    range_ = [r[len('gi'):].split('-') for r in string.split(',') if r.startswith('gi')]
    return set([i for r in range_ for i in range(int(r[0]), int(r[-1]) + 1)])

@staticmethod
def _integer_set_to_string_range(set_):
    list_ = sorted(set_)

    if not list_:
        return ''

    range_ = []
    current_range = [list_[0], list_[0]]

    for item in list_[1:]:
        # A new range is starting, let's commit
        if item != current_range[1] + 1:
            _integer_set_to_string_range_(current_range, range_)
            current_range = [item, item]
        else:
            current_range[1] = current_range[1] + 1

    # Handle the last range
    _integer_set_to_string_range_(current_range, range_)

    return ",".join((str(r) for r in range_))

def _integer_set_to_string_range_(current_range, range_):
    range_width = current_range[1] - current_range[0]

    if range_width > 1:
        range_.append("{}-{}".format(*current_range))
    elif range_width == 1:
        range_.extend(current_range)
    else:
        range_.append(current_range[0])

@staticmethod
def _set_diff(old, new):
    intersect = new.intersection(old)
    added = new - intersect
    removed = old - intersect

    return added, removed

@staticmethod
def _dict_diff(old, new):
    set_old, set_new = set(old.keys()), set(new.keys())
    intersect = set_new.intersection(set_old)

    changed = set(o for o in intersect if old[o] != new[o])
    return changed
