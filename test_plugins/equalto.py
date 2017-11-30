from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from ansible import errors

def equalto(value, other):
    return bool(value == other)

class TestModule(object):
    ''' Ansible file jinja2 tests '''

    def tests(self):
        return {
            'equalto' : equalto,
        }
