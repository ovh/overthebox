# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :

import serial

PORT = '/dev/ttyS0'
BAUDRATE = 115200
BYTESIZE = serial.EIGHTBITS
PARITY = serial.PARITY_NONE
STOPBITS = serial.STOPBITS_ONE

READ_TIMEOUT = 0.05

# After 10 minutes of idle time, the switch will auto-logout
# The CLI is then blocked during 8 seconds
# If our script is launched during those 8 seconds, we need to ensure we'll at least wait 8 seconds
# READ_RETRIES = ceil(log_2((8/READ_TIMEOUT) + 1) - 1)
READ_RETRIES = 7

BAD_ECHO_BUDGET = 10

# Long write timeout does not impact the execution speed
# So it's convenient to set a high one: we don't need to implement any retry
# If the long write timeout is exceeded, we can crash
WRITE_TIMEOUT = 8

USER, PASSWORD = "admin", "admin"

UCI_NAME = 'otbv2sw'
MODEL = 'TG-NET S3500-15G-2F'
PORT_MIN = 1
PORT_CPU = 15
PORT_MAX = 18
PORT_COUNT = (PORT_MAX - PORT_MIN) + 1
VID_MAX = 4094
DEFAULT_VLAN = 1
