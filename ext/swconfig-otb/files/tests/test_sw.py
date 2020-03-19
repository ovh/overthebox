# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
# pylint: disable=protected-access,line-too-long
import unittest
from swconfig_otb.sw import Sw

class TestSw(unittest.TestCase):
    def __init__(self, *args, **kwargs):
        super(TestSw, self).__init__(*args, **kwargs)
        self.coms = []
        self.coms_check = []

    def test_filter(self):
        inputs = [
            "*Jan 14 2000 09:37:33: %System-5: New console connection for user admin, source async  ACCEPTED",
            "martinsw# ",
            "Password: ",
            "Username: *Jan 14 2000 09:44:46: %System-5: New console connection for user admin, source async  REJECTED",
            "*Jan 14 2000 09:55:24: %Port-5: Port gi2 link up",
            "*Jan 14 2000 09:55:24: %Port-5: Port gi8 link up",
            "*Jan 14 2000 09:55:27: %Port-5: Port gi2 link down",
            "*Jan 14 2000 09:55:27: %Port-5: Port gi8 link down",
            "martinsw(config-vlan)# *Jan 14 2000 09:59:53: %VLAN-5: VLAN 75 is added, default name is VLAN0075",
            "martinsw(config)# *Jan 14 2000 10:10:58: %VLAN-5: VLAN 75 is removed",
        ]

        comment_on_single_line = [0, 4, 5, 6, 7]
        no_comment = [1, 2]

        # Lines containing only a comment
        for com_idx in comment_on_single_line:
            self.coms_check.append(inputs[com_idx])
            self.assertEqual(Sw._filter(inputs[com_idx], self.coms), "")
            self.assertEqual(self.coms, self.coms_check)

        # Lines containing only normal output (no comment)
        for no_comment_idx in no_comment:
            self.assertEqual(Sw._filter(inputs[no_comment_idx], self.coms), inputs[no_comment_idx])
            self.assertEqual(self.coms, self.coms_check)

        # Lines with mixed comment and normal output
        self._test_filter_mixed_comment(inputs[3], "Username: ", "*Jan 14 2000 09:44:46: %System-5: New console connection for user admin, source async  REJECTED")
        self._test_filter_mixed_comment(inputs[8], "martinsw(config-vlan)# ", "*Jan 14 2000 09:59:53: %VLAN-5: VLAN 75 is added, default name is VLAN0075")
        self._test_filter_mixed_comment(inputs[9], "martinsw(config)# ", "*Jan 14 2000 10:10:58: %VLAN-5: VLAN 75 is removed")

    def _test_filter_mixed_comment(self, line, normal_part, com_part):
        self.assertEqual(Sw._filter(line, self.coms), normal_part)
        self.coms_check.append(com_part)
        self.assertEqual(self.coms, self.coms_check)
