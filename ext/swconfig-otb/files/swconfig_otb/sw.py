# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
"""OTBv2 Switch module

This module implements primitives to serially interact with the TG-NET S3500-15G-2F switch.
"""

import re
import logging
import serial
import subprocess

from swconfig_otb.sw_state import _States
import swconfig_otb.config as config

logger = logging.getLogger('swconfig')


class Sw(object):
    """Represent a serial connection to a TG-NET S3500-15G-2F switch."""

    _MORE_MAGIC = ["\x08", "\x1b[A\x1b[2K"]

    # This is a trick used to be able to define some parts of the class in a separated file
    from swconfig_otb.sw_except import BadEchoBudgetExceededError, LoginError, SerialPortBusyError
    from swconfig_otb.sw_except import StateAssertionError, _assert_state
    from swconfig_otb.sw_vlan import _set_diff, _dict_diff
    from swconfig_otb.sw_vlan import _if_str_to_integer_set, _integer_set_to_string_range
    from swconfig_otb.sw_vlan import _parse_vlans, _create_vid, _delete_vid
    from swconfig_otb.sw_vlan import update_vlan_conf, init_vlan_config_datastruct

    def __init__(self):
        try:
            self.sock = serial.Serial()
            self.sock.port = config.PORT
            self.sock.baudrate = config.BAUDRATE
            self.sock.bytesize = config.BYTESIZE
            self.sock.parity = config.PARITY
            self.sock.stopbits = config.STOPBITS
            self.sock.timeout = config.READ_TIMEOUT
            self.sock.writeTimeout = config.WRITE_TIMEOUT
        except(serial.SerialException, ValueError):
            logger.error("Device %s was not found or cannot be configured", config.PORT)
            raise

        self.state = None
        self.hostname = None
        self._bad_echo = 0

    def __enter__(self):
        self.open_()
        return self

    def __exit__(self, type_, value, traceback):
        self.close()

    def open_(self):
        """Open the serial connection and go to the admin main prompt

        Instead of calling me, consider using 'with' statement if that suits your needs
        """
        # Check whether the serial TTY is already open by another process
        lsof = subprocess.Popen(['lsof', self.sock.port], stdout=subprocess.PIPE)
        lsof.communicate()
        if lsof.returncode == 0:
            raise self.SerialPortBusyError("Serial TTY '%s' is already open by another process. " \
                                           "Aborting." % (self.sock.port))

        self.sock.open()
        self._goto_admin_main_prompt()

    def close(self):
        """Close the serial connection and reset the state so this instance could be reused

        Instead of calling me, consider using 'with' statement if that suits your needs
        """
        self.sock.close()
        self.state = None
        self.hostname = None
        self._bad_echo = 0

    def _recv(self, auto_more, timeout):
        """Receive everything. If needed, we'll ask the switch for MOOORE. :p

        Some commands may activate a pager when the answer becomes too big.
        We would then stay stuck with a --More-- at the bottom.
        This method receives output as many times as needed and gather the whole output.

        Args:
            auto_more: When true, we'll keep asking for more and get the full output
                Otherwise the More logic is disabled and --More-- will be received in the output
                It will be up to the caller to deal with the fact that we're still in a More state
            timeout: If the cmd is known to require a longer Switch CPU processing time than usual,
                a timeout can be specified. It will be used only for the first read.
        """
        self.sock.timeout = timeout # Increase the timeout to the one specified
        whole_out, all_comments = self._recv_once_retry()
        self.sock.timeout = config.READ_TIMEOUT # Reset to a lower timeout for subsequent reads

        # If we're now in a more, ask for MOOOORE to get the full output! :p
        while auto_more and self.state == _States.MORE:
            try:
                self.sock.write(" ") # Sending a space gives us more lines than a LF
            except serial.SerialTimeoutException:
                logger.error("Write timeout has been exceeded. Is the switch dead?")
                raise

            out, comments = self._recv_once_retry()

            if out[0] == self._MORE_MAGIC[0] and out[1].startswith(self._MORE_MAGIC[1]):
                out.pop(0) # Remove the BackSpace (it occupies a whole line)
                out[0] = out[0][len(self._MORE_MAGIC[1]):] # Strip the ^[A^[2K from the second line

            whole_out.extend(out)
            all_comments.extend(comments)

        return (whole_out, all_comments)

    def _recv_once_retry(self):
        """Try to receive once, and retries with increasing timeout if it fails"""
        for _ in range(config.READ_RETRIES + 1):
            try:
                return self._recv_once()
            except serial.SerialTimeoutException:
                logger.error("Read failed with timeout %fs. Will retry...", self.sock.timeout)
                self.sock.timeout = self.sock.timeout * 2

        msg = "All read attempts timed out. Is the switch dead or the port already busy?"
        logger.error(msg)
        raise serial.SerialTimeoutException(msg)

    def _recv_once(self):
        """Receive once, filter output and update switch state by parsing prompt"""
        # First, call self.readlines().
        # It reads from serial port and gets a list with one line per list item.
        # In each of the list's item, remove any \r or \n, but only at end of line (right strip)
        # For each line of the output, give it to _filter
        # This will filter out switch comments and put them into a separated list
        # Finally, use filter(None, list) to remove empty elements
        coms = []
        try:
            out = filter(None, [self._filter(l.rstrip("\r\n"), coms) for l in self.sock.readlines()])
        except serial.SerialException:
            logger.error("The switch port seems to be busy. Aborting")
            raise

        # out should never be empty. Otherwise it means we have a problem...
        if not out:
            raise serial.SerialTimeoutException("The read timed out.")

        # However, out may become empty after prompt parsing (prompt will be removed)
        self.state = self._parse_prompt(out)
        if self.state:
            logger.debug("Switch state is: '%s'", self.state.name)
        else:
            logger.error("Switch state is unknown")

        return (out, coms)

    @staticmethod
    def _filter(line, comments):
        """Remove comments and push them to a separated list

        Comments always end by CRLF, sometimes after prompt, sometimes on a new line
        They start with a '*' and a date in the form '*Jan 13 2000 11:25:20: '
        Then come a type prefix and the message:
            %System-5: New console connection for user admin, source async  ACCEPTED
            %Port-5: Port gi6 link down
            %Port-5: Port gi4 link up

        Args:
            line: The current line being processed
            comments: A reference to a list where we can push the comments we find

        Returns:
            The modified output line (it can become empty if the whole line was a comment)
        """
        # This regex matches a switch comment
        comment_regex = re.search(r'(\*.*: %.*: .*)', line)

        # If we've found a comment, move it to a dedicated list
        if comment_regex and comment_regex.group():
            comments.append(comment_regex.group())
            line = line[:comment_regex.span()[0]]

        return line

    def _send(self, string, bypass_echo_check=True, auto_more=False, timeout=config.READ_TIMEOUT):
        """Send an arbitrary string to the switch and get the answer

        Args:
            string: The string to send to the switch
            bypass_echo_check: When True, the echo will be part of the global answer
                Otherwise it'll be consumed char by char and will be checked
            auto_more: When true, we'll keep asking for more and get the full output
                Otherwise the More logic is disabled and --More-- will be received in the output
                It will be up to the caller to deal with the fact that we're still in a More state
            timeout: If the cmd is known to require a longer Switch CPU processing time than usual,
                a timeout can be specified. It will be used only for the first read.
        """
        # When sending a command, it's safer to send it char by char, and wait for the echo
        # Why? Try to connect to the switch, go to the Username: prompt.
        # Then, in order to simulate high speed TX, copy "admin" and paste it inside the console.
        # The echo arrives in a random order. The behaviour is completely unreliable.
        # (Actually, only the echo arrives out of order. But the switch got it in the right order.)
        for char in string:
            try:
                self.sock.write(char)
            except serial.SerialTimeoutException:
                logger.error("Writetimeout has been exceeded. Is the switch dead?")
                raise

            # If we don't care about echo, don't consume and don't check it
            if bypass_echo_check:
                continue

            # Skip Carriage Return (we never send CR, the switch always echo with CR)
            echo = self.sock.read(1)
            echo = echo if echo != "\r" else self.sock.read(1)

            # Each character we get should be the echo of what we just sent
            # '*' is also considered to be a good password echo
            # If we encounter wrong echo, maybe we just got a garbage line from the switch
            # In that case we flush the input buffer so that we stop reading the garbage immediately
            # That way, the next time we read one character, it should be again our echo
            # We only tolerate a given fixed "wrong echo budget"
            # Note: In password echo at the end, there is a "\n" echo which is considered correct
            expected = '*' if self.state == _States.LOGIN_PASSWORD and echo != char else char
            if echo != expected:
                self._bad_echo = self._bad_echo + 1
                logger.warn("Invalid echo: expected '%c' (%s), got '%c' (%s)",
                            expected, hex(ord(expected)), echo, hex(ord(echo)))
                self.sock.flushInput()

                if self._bad_echo > config.BAD_ECHO_BUDGET:
                    raise self.BadEchoBudgetExceededError("Bad echo budget exceeded. Giving up.")

        return self._recv(auto_more, timeout)

    def send_cmd(self, cmd, timeout=config.READ_TIMEOUT, **kwargs):
        """Send a command to the switch, check the echo and get the full output.

        Args:
            cmd: The command to send. Do not add any LF at the end.
            timeout: If the cmd is known to require a longer Switch CPU processing time than usual,
                a timeout can be specified. It will be used only for the first read.
            assert_state: If needed, pass a kwarg 'assert_state'.
                After the send and reception of the answer are complete,
                we'll crash if the switch's state is not the one specified.

        Returns:
            A tuple (out, comments)
                out: List of strings of the regular output (no comments inside)
                comments: List of strings of the switch comments
        """
        ret = self._send("%s\n" % (cmd), False, True, timeout)
        if 'assert_state' in kwargs:
            self._assert_state(kwargs['assert_state'])

        return ret

    def _goto_admin_main_prompt(self):
        """Bring the switch to the known state "hostname# " prompt (from known or unknown state)

        If necessary, it will login, exit some menus, escape an ongoing "--More--"...
        """
        self.sock.flushInput()

        # We don't know where we are, let's find out :)
        if self.state is None:
            self._send("\n")

        # Now, we know where we are. Let's go to the ADMIN_MAIN state :)

        # If the state is press any key, let's press a key!
        if self.state == _States.PRESS_ANY_KEY:
            self._send("\n")

        # We are already where we want to go. Stop here
        if self.state == _States.ADMIN_MAIN:
            return

        if self.state == _States.MORE:
            logger.debug("Sending one ETX (CTRL+C) to escape --More-- state")
            self._send("\x03")

        # We are logged in and at the "hostname> " prompt. Let's enter "hostname# " prompt
        elif self.state == _States.USER_MAIN:
            self.send_cmd("enable")

        # We're logged in and in some menus. Just exit them
        elif self.state in [_States.CONFIG, _States.CONFIG_VLAN,
                            _States.CONFIG_IF, _States.CONFIG_IF_RANGE]:
            self.send_cmd("end")

        # We're in the login prompt. Just login now!
        elif self.state in [_States.LOGIN_USERNAME, _States.LOGIN_PASSWORD]:
            self._login()

        # Crash if the switch is not in the ADMIN_MAIN state now
        self._assert_state(_States.ADMIN_MAIN)

    def _parse_prompt(self, out):
        """Analyze the received output to determine the switch state

        Args:
            out: A list with the output that we'll use to determine the state

        Returns:
            A state if we found out, or None if we still don't known where we are
        """
        last_line = out[-1]

        # States without hostname information in the prompt
        for state in [_States.PRESS_ANY_KEY, _States.LOGIN_USERNAME,
                      _States.LOGIN_PASSWORD, _States.MORE]:
            if last_line.startswith(state.prompt_needle):
                if state == _States.MORE:
                    out.pop() # Remove the --More-- from the output!
                return state

        # Hostname determination
        if not self.hostname and not self._determine_hostname(last_line):
            return None

        # States containing the hostname in the prompt
        for state in [_States.CONFIG, _States.CONFIG_VLAN, _States.CONFIG_IF,
                      _States.CONFIG_IF_RANGE, _States.ADMIN_MAIN, _States.USER_MAIN]:
            if last_line.startswith(self.hostname + state.prompt_needle):
                out.pop() # Remove the prompt from the output :)
                return state

        # Unknown state
        return None

    def _determine_hostname(self, output_last_line):
        """Extract the hostname from the prompt and store it"""
        hostname_regex = re.search(r'(?P<hostname>[^(]+).*(?:>|#) ', output_last_line)
        if hostname_regex and hostname_regex.group('hostname'):
            self.hostname = hostname_regex.group('hostname')
            logger.debug("Hostname '%s' detected", self.hostname)
            return True
        else:
            logger.error("Unable to determine hostname :'(")
            return False

    def _login(self):
        """Automatically login into the switch

        Only call me if we are in the LOGIN_USERNAME or LOGIN_PASSWORD state.
        """
        if self.state == _States.LOGIN_USERNAME:
            out, _ = self.send_cmd(config.USER)
            # The switch rejects us immediately if the username doesn't exist
            if any("Incorrect User Name" in l for l in out):
                raise self.LoginError("The switch claims the username is invalid. " \
                                      "Check that the credentials are correct.")

            # If we got here, the login has been accepted. Let's continue and send the password

        # There are 2 possible execution flows:
        #  1) We've just sent the login above, now it's time to send the password
        #  2) We arrive directly here as the first if above was skipped
        # This 2th case is rare but could occur if the state is following before launching swconfig:
        # (Username fully typed in but no Line Feed entered)
        #  Username: admin
        # In this case we'll transition from UNKNOWN to LOGIN_PASSWORD state directly

        # We should have entered password state now
        try:
            self._assert_state(_States.LOGIN_PASSWORD)
        except self.StateAssertionError:
            logger.error("Unexpected error during login phase: " \
                         "we should have entered password state now")
            raise

        out, comments = self.send_cmd(config.PASSWORD)
        if any("ACCEPTED" in c for c in comments):
            return

        if any("REJECTED" in c for c in comments):
            raise self.LoginError("The switch rejected the password. " \
                                  "Check that the credentials are correct.")

        raise self.LoginError("Unexpected error after sending password: " \
                              "no ACCEPTED nor REJECTED found")
