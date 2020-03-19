# -*- coding: utf-8 -*-
# vim: set expandtab tabstop=4 shiftwidth=4 softtabstop=4 :
"""UCI Parser"""

import shlex

def uci_to_dict(config_name):
    """Parse an UCI file in a very naive manner and return a dict

    This parser is very primitive and only understands 'config' or 'option' keywords
    """
    ret = {}
    filepath = '/etc/config/' + config_name

    with open(filepath) as handle:
        current_config = None

        # Browse the file line by line but get rid of indentation and empty lines
        # We use shlex.split to preserve quoted strings in one piece when splitting:
        # "test 'hello good morning' test2" will become ["test", "'hello good morning'", "test2"]
        for line in (shlex.split(l2) for l2 in (l1.strip() for l1 in handle) if l2):
            # The policy here is to skip any line we don't understand
            # without throwing an error as we are a naive parser

            # A line should have at least two arguments (ex: config interface)
            if len(line) < 2:
                continue

            keyword, name = line[0], line[1]
            del line[0:2]

            # We only understand 'config' and 'option' keywords for now...
            if keyword not in ['config', 'option']:
                continue

            # We got an 'option' keyword but we don't know to which 'config' it belongs
            if not current_config and keyword != 'config':
                continue

            # We found a 'config' keyword. Let's append a new dict to our list for this config
            # If this is the first occurrence for this config, create the list before appending
            if keyword == 'config':
                current_config = name
                ret.setdefault(current_config, []).append({})
                continue

            # From now on, the keyword must be 'option'
            # Otherwise the programmer really doesn't know what he is doing...
            assert keyword == 'option'

            # Options should have at least a value (we'll only care about the first one)
            if len(line) < 1:
                continue

            # Remove leading and trailing quotes if present, then store the option and its value!
            option_name, option_value = name, line[0].strip("'")
            ret[current_config][-1][option_name] = option_value

    return ret
