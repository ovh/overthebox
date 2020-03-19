# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
"""Switch states definition"""

class _State(object):
    def __init__(self, name, prompt_needle):
        self.name = name
        self.prompt_needle = prompt_needle

class _States(object):
    PRESS_ANY_KEY = _State("Press any key", "Press any key to continue")
    USER_MAIN = _State("User prompt", "> ")
    ADMIN_MAIN = _State("Admin prompt", "# ")
    CONFIG = _State("Config", "(config)# ")
    CONFIG_VLAN = _State("Config VLAN", "(config-vlan)# ")
    CONFIG_IF = _State("Config IF", "(config-if)# ")
    CONFIG_IF_RANGE = _State("Config IF Range", "(config-if-range)# ")
    LOGIN_USERNAME = _State("Login (username)", "Username: ")
    LOGIN_PASSWORD = _State("Login (password)", "Password: ")
    MORE = _State("More", "--More--")
