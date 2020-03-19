# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
"""OTBv2 Switch module, extension with exceptions definition

This module adds exceptions and methods to the class Sw
"""

import logging
logger = logging.getLogger('swconfig')

class AbstractSwitchException(Exception):
    def __init__(self, *args, **kwargs):
        Exception.__init__(self, *args, **kwargs)
        logger.error(self.message)


class SerialPortBusyError(AbstractSwitchException):
    """Serial TTY port is already open by another process"""
    pass

class BadEchoBudgetExceededError(AbstractSwitchException):
    """Wrong echo budget has been exceeded

    When sending a command to the switch, we check the echo char by char.
    We only tolerate a maximum bad echo budget. When it's exceeded, this exception will be raised.
    """
    pass

class LoginError(AbstractSwitchException):
    """Login was not successful"""
    pass

class VlanError(AbstractSwitchException):
    """Vlan creation or deletion was not successful"""
    pass

class StateAssertionError(AbstractSwitchException):
    """Switch's state is unexpected

    Describe an abnormal situation where the switch's state is not the one expected.
    """
    pass

def _assert_state(self, state):
    if self.state != state:
        actual_state_name = "Unknown" if not self.state else self.state.name
        raise StateAssertionError("Unexpected switch state. Expected: '%s', got '%s'."
                                  % (state.name, actual_state_name))
