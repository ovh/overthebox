# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
# pylint: disable=protected-access
import unittest
from swconfig_otb.sw import Sw

class TestSwVlan(unittest.TestCase):
    def test_integer_set_to_string_range(self):
        ios = [
            (set(), ''),
            (set([2]), '2'),
            (set([0]), '0'),
            (set([1, 15]), '1,15'),
            (set([15, 1]), '1,15'),
            (set([3, 2]), '2,3'),
            (set([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]), '1-13'),
            (set([7, 12, 1, 9, 18, 15, 16, 17]), '1,7,9,12,15-18'),
            (set([7, 12, 1, 9, 18, 15, 16, 17]), '1,7,9,12,15-18'),
            (set([7, 15, 6, 16, 5, 14, 4, 18]), '4-7,14-16,18'),
            (set([7, 6, 5, 4, 1, 2, 10, 12, 11, 14, 13, 16, 17, 18, 25]), '1,2,4-7,10-14,16-18,25'),
        ]

        for (input_, output) in ios:
            self.assertEqual(Sw._integer_set_to_string_range(input_), output)

    def test_if_str_to_integer_set(self):
        ios = [
            ('', set([])),
            ('---', set([])),
            ('lag1', set([])),
            ('lag7-15,lag18', set([])),
            ('gi2', set([2])),
            ('gi2,gi9,gi17', set([2, 9, 17])),
            ('gi2,lag2,lag4-7,gi17', set([2, 17])),
            ('gi1,gi4-6,lag1-8', set([1, 4, 5, 6])),
            ('gi2-3,gi7-12,gi15-16,gi18', set([2, 3, 7, 8, 9, 10, 11, 12, 15, 16, 18])),
            ('gi7-15,gi1,lag18,gi3-5,gi17', set([1, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17])),
        ]

        for (input_, output) in ios:
            self.assertEqual(Sw._if_str_to_integer_set(input_), output)
