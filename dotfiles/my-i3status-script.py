#!/usr/bin/env python3


import enum
import sys
import os


class Color(enum.Enum):
    GOOD = '#859900'
    NORMAL = '#93A1A1'
    DEGRADED = '#CB4B16'
    BAD = '#DC322F'


def build_item(name: str, text: str, color: Color) -> str:
    item_template = \
        '{"name":"%s","markup":"none","color":"%s","full_text":"%s"}'
    return item_template.format(name, color.value, text)


def build_boolean(name: str, text: str, exp: bool) -> str:
    return build_item(name, text, Color.GOOD if exp else Color.BAD)


def execute(*cmd: str) -> bool:
    return os.system(' '.join(cmd) + ' > /dev/null 2>&1') == 0


def has_ping(host: str) -> bool:
    return execute('ping -c 1 -W 1 ' + host)


def append_custom(original: str) -> str:
    if original.startswith('{') or original == '[':
        return original
    prefix_index = original.find('[')
    if prefix_index < 0:
        return original

    output_prefix = original[:prefix_index + 1]
    output_postfix = original[len(output_prefix):]
    items = []

    items.append(build_boolean('internet', '', has_ping('google.com')))

    custom = (','.join(items) + ',') if len(items) > 0 else ''
    return output_prefix + custom + output_postfix


if __name__ == '__main__':
    #print(append_custom(sys.argv[1]))
    print(sys.argv[1])

