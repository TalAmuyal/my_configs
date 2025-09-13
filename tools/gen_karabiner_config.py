# /// script
# requires-python = ">=3.12"
# dependencies = [
#    "typer",
# ]
# ///

import dataclasses
import json
import pathlib

import typer


OPTION_KEYS = (
    "option",
    "left_option",
    "right_option",
)

CTRL_KEYS = (
    "left_control",
    "right_control",
    "control",
)


@dataclasses.dataclass(frozen=True)
class Acl:
    instruction: str
    patterns: tuple[str, ...]


"""
class OnlyFor(Acl):  # WHITE_LIST
    def __init__(self, *patterns: str) -> None:
        super().__init__(
            instruction="frontmost_application_if",
            patterns=patterns,
        )
"""


class ExceptFor(Acl):  # BLACK_LIST
    def __init__(self, *patterns: str) -> None:
        super().__init__(
            instruction="frontmost_application_unless",
            patterns=patterns,
        )


r"""
map_only_for_browsers = OnlyFor(
    r"^org\.mozilla\.firefox$",
    r"^com\.google\.Chrome$",
    r"^com\.apple\.Safari$",
)
"""

map_except_for_terminals = ExceptFor(
    r"^com\.apple\.Terminal$",
    r"^com\.googlecode\.iterm2$",
    r"^co\.zeit\.hyperterm$",
    r"^co\.zeit\.hyper$",
    r"alacritty",
    r"kitty",
    r"oni",
    r"veonim",
)


@dataclasses.dataclass(frozen=True)
class ModKeyMapping:
    description: str
    key: str
    from_mod_keys: tuple[str, ...]
    to_mod_key: str
    acl: Acl

    def make_rules(self) -> list[dict]:
        return [
            self._make_rule(form_mod_key)
            for form_mod_key in self.from_mod_keys
        ]

    def _make_rule(
        self,
        from_mandatory: str,
        from_optional: str = "any",
    ) -> dict:
        condition = {
            "type": self.acl.instruction,
            "bundle_identifiers": self.acl.patterns,
        }
        manipulator = {
            "conditions": [condition],
            "type": "basic",
        }
        manipulator.update(
            map_key(
                key=self.key,
                from_mandatory=from_mandatory,
                from_optional=from_optional,
                to_modifier=self.to_mod_key,
            )
        )
        rule = {
            "description": self.description,
            "manipulators": [manipulator],
        }
        return rule


class CtrlMapping(ModKeyMapping):
    def __init__(
        self,
        description: str,
        key: str,
    ) -> None:
        super().__init__(
            description=description,
            key=key,
            from_mod_keys=CTRL_KEYS,
            to_mod_key="left_command",
            acl=map_except_for_terminals,
        )


class AltMapping(ModKeyMapping):
    def __init__(
        self,
        description: str,
        key: str,
    ) -> None:
        super().__init__(
            description=description,
            key=key,
            from_mod_keys=OPTION_KEYS,
            to_mod_key="left_command",
            acl=map_except_for_terminals,
        )


def make_compund_key(
    key: str,
    modifiers=None,
) -> dict:
    if type(modifiers) is list:
        modifiers = [m for m in modifiers if m]
    ck = {"key_code": key}
    if modifiers:
        ck["modifiers"] = modifiers
    return ck


def listify(x, should):
    return [x] if should else x


def map_key(
    key: str,
    from_mandatory=None,
    from_optional=None,
    to_modifier=None,
    listify_to=True,
) -> dict:
    from_kvs = {("mandatory", from_mandatory), ("optional", from_optional)}
    from_modifiers = {k: [v] for k, v in from_kvs if v is not None}
    mapping = {
        "from": make_compund_key(key, from_modifiers),
        "to": listify(make_compund_key(key, [to_modifier]), listify_to),
    }
    return mapping


mappings: list[ModKeyMapping] = [
    CtrlMapping("copy", "c"),
    CtrlMapping("cut", "x"),
    CtrlMapping("paste", "v"),
    CtrlMapping("undo", "z"),
    CtrlMapping("redo", "y"),
    CtrlMapping("select-all", "a"),
    CtrlMapping("save", "s"),
    CtrlMapping("reload(Ctrl+R)", "r"),
    CtrlMapping("new tab", "t"),
    CtrlMapping("find", "f"),
    CtrlMapping("new", "n"),
    CtrlMapping("slack-search / Google Docs link", "k"),
    CtrlMapping("bold", "b"),
    CtrlMapping("underline", "u"),
    CtrlMapping("italics", "i"),
    CtrlMapping("Close tab", "w"),
    CtrlMapping("end-of-line", "right_arrow"),
    CtrlMapping("start-of-line", "left_arrow"),
    CtrlMapping("Open location", "l"),
    CtrlMapping("Ctrl+Enter", "return_or_enter"),
    AltMapping("Back", "left_arrow"),
    AltMapping("Forward", "right_arrow"),
]

profile = {
    "name": "My profile",
    "selected": True,
    "simple_modifications": [
        {
            "from": {
                "key_code": "caps_lock",
            },
            "to": [
                {
                    "key_code": "left_control",
                },
            ],
        },
        {
            "from": {
                "key_code": "grave_accent_and_tilde",
            },
            "to": [
                {
                    "key_code": "non_us_backslash",
                },
            ],
        },
    ],
    "complex_modifications": {
        "parameters": {
            "basic.simultaneous_threshold_milliseconds": 50,
            "basic.to_delayed_action_delay_milliseconds": 500,
            "basic.to_if_alone_timeout_milliseconds": 1000,
            "basic.to_if_held_down_threshold_milliseconds": 500,
        },
        "rules": (
            [
                rule
                for mapping in mappings
                for rule in mapping.make_rules()
            ]
            + [
                {
                    "description": "Ctrl+Shift+V to Paste",
                    "manipulators": [
                        {
                            "type": "basic",
                            "from": {
                                "key_code": "v",
                                "modifiers": {
                                    "mandatory": ["control", "shift"],
                                },
                            },
                            "to": [
                                {
                                    "key_code": "v",
                                    "modifiers": ["command"],
                                },
                            ],
                        }
                    ],
                }
            ]
            + [
                {
                    "description": f"CMD+Option+{i} to Ctrl+Alt+{i} (GDoc H{i})",
                    "manipulators": [
                        {
                            "type": "basic",
                            "from": {
                                "key_code": f"{i}",
                                "modifiers": {
                                    "mandatory": ["control", "option"],
                                },
                            },
                            "to": [
                                {
                                    "key_code": f"{i}",
                                    "modifiers": ["command", "option"],
                                },
                            ],
                        }
                    ],
                }
                for i in range(1, 10)
            ]
        ),
    },
    "fn_function_keys": [
        map_key(
            f"f{i + 1}",
            listify_to=False)
        for i in range(12)
    ],
    "devices": [],
    "virtual_hid_keyboard": {
        "country_code": 0,
        "keyboard_type_v2": "iso",
    },
}


config = {
    "global": {
        "check_for_updates_on_startup": True,
        "show_in_menu_bar": True,
        "show_profile_name_in_menu_bar": False,
    },
    "profiles": [profile],
}


def main(
    output_file_path: pathlib.Path,
) -> None:
    if not (parent_dir := output_file_path.parent).exists():
        parent_dir.mkdir(parents=True, exist_ok=True)

    dumped_config = json.dumps(config, sort_keys=False, indent=4).strip()

    if not output_file_path.exists() or output_file_path.read_text().strip() != dumped_config:
        output_file_path.write_text(dumped_config)

if __name__ == "__main__":
    typer.run(main)
