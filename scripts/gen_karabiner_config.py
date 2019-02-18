#!/usr/local/bin/python3

import json


EXAMPTION_APPS = [
    r"^com\.apple\.Terminal$",
    r"^com\.googlecode\.iterm2$",
    r"^co\.zeit\.hyperterm$",
    r"^co\.zeit\.hyper$",
    r"oni",
]

BROWSERS = [
    r'^org\.mozilla\.firefox$',
    r'^com\.google\.Chrome$',
    r'^com\.apple\.Safari$',
]


class ACL:
    WHITE_LIST = 'frontmost_application_if'
    BLACK_LIST = 'frontmost_application_unless'


class DIR:
    FROM = 'from'
    TO = 'to'


def make_rule(
        description: str,
        key: str,
        from_mandatory,
        from_optional,
        to_modifier,
        acl: str,
        apps_list: str,
        ):
    condition = {
        'bundle_identifiers': apps_list,
        'type': acl,
    }
    manipulator = {
        'conditions': [condition],
        'type': 'basic',
    }
    manipulator.update(map_key(
        key=key,
        from_mandatory=from_mandatory,
        from_optional=from_optional,
        to_modifier=to_modifier,
    ))
    rule = {
        'description': description,
        'manipulators': [manipulator],
    }
    return rule


def make_compund_key(
        key: str,
        modifiers=None,
        ):
    if type(modifiers) is list:
        modifiers = [m for m in modifiers if m]
    ck = {'key_code': key}
    if modifiers:
        ck['modifiers'] = modifiers
    return ck


def listify(x, should):
    return [x] if should else x


def map_key(
        key: str,
        from_mandatory=None,
        from_optional=None,
        to_modifier=None,
        listify_to=True,
        ):
    from_kvs = {('mandatory', from_mandatory), ('optional', from_optional)}
    from_modifiers = {k: [v] for k, v in from_kvs if v is not None}
    mapping = {
        DIR.FROM: make_compund_key(key, from_modifiers),
        DIR.TO: listify(make_compund_key(key, [to_modifier]), listify_to),
    }
    return mapping


def map_ctrl_to_cmd(
        description: str,
        letter: str,
        acl: str,
        apps_list: str,
        ):
    return make_rule(
        description,
        letter,
        'control',
        'any',
        'left_command',
        acl,
        apps_list,
    )


def reset_f_key(n):
    return map_key(f'f{n}', listify_to=False)


ctrl_to_cmd_mappings = [
    ('copy', 'c'),
    ('cut', 'x'),
    ('paste', 'v'),
    ('undo', 'z'),
    ('select-all', 'a'),
    ('save', 's'),
    ('reload(Ctrl+R)', 'r'),
    ('new tab', 't'),
    ('find', 'f'),
    ('slack-search', 'k'),
]

rules = [
    map_ctrl_to_cmd(d, l, ACL.BLACK_LIST, EXAMPTION_APPS)
    for d, l in ctrl_to_cmd_mappings
] + [map_ctrl_to_cmd('open location', 'l', ACL.WHITE_LIST, BROWSERS)] + [
    make_rule(
        d,
        l,
        'option',
        'any',
        'left_command',
        ACL.WHITE_LIST,
        BROWSERS,
    )
    for d, l in (('Back', 'left_arrow'), ('Forward', 'right_arrow'))
]


profile = {
    'name': 'My profile',
    'selected': True,
    'simple_modifications': [],
    'complex_modifications': {
        'parameters': {
            'basic.simultaneous_threshold_milliseconds': 50,
            'basic.to_delayed_action_delay_milliseconds': 500,
            'basic.to_if_alone_timeout_milliseconds': 1000,
            'basic.to_if_held_down_threshold_milliseconds': 500,
        },
        'rules': rules,
    },
    'fn_function_keys': [reset_f_key(i + 1) for i in range(12)],
    'devices': [],
    'virtual_hid_keyboard': {'country_code': 0},
}


config = {
    'global': {
        'check_for_updates_on_startup': True,
        'show_in_menu_bar': True,
        'show_profile_name_in_menu_bar': False,
    },
    'profiles': [profile],
}

with open('karabiner.json', 'w') as f:
    json.dump(config, f, sort_keys=True, indent=4)

