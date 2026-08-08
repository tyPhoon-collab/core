---
name: karabiner-config
description: Edit, review, and verify this repository's Karabiner-Elements configuration in files/karabiner/karabiner.json. Use when changing keymaps, tap/hold layers, app launch mappings, profile rules, or diagnosing why a Karabiner mapping does not activate.
---

# Karabiner Config

## Workflow

1. Treat `files/karabiner/karabiner.json` as the source of truth.
2. Read `modules/programs/karabiner.nix` and `llms.md` before changing deployment or runtime behavior.
3. Inspect selected profiles, rule order, existing variables, and device-specific modifications with `jq`.
4. Identify whether `from.key_code` means the physical key or the intended character. In the 大西配列 profile, use the physical key that produces the intended character after layout translation.
5. Put layer interceptors before unconditional layout rules such as `大西配列`. Karabiner matches the physical event; a preceding unconditional manipulator can consume it before a later layer rule sees it.
6. Keep app launch mappings in a separate rule. Use `variable_if` for the layer condition and `software_function.open_application.bundle_identifier` for application activation.
7. Preserve native shortcuts. Do not add `optional: ["any"]` to the Tab trigger unless intentionally capturing combinations such as `Cmd+Tab`.
8. Make the smallest edit. Do not copy current keymap values into README or `llms.md`.

## Tap/hold layer pattern

Reuse the repository's established pattern:

- `to`: set layer variable to `1`
- `to_after_key_up`: reset variable to `0`
- `to_if_alone`: preserve the tap action
- layer actions: `conditions` with `variable_if`

Use `to_if_held_down` only when a real hold threshold is required. Do not replace the established immediate layer pattern merely because the layer is called “long press”.

## Verification

Run all checks from repository root. Prefix shell commands with `rtk`.

```bash
rtk jq empty files/karabiner/karabiner.json
rtk karabiner_cli --lint-complex-modifications 'files/karabiner/karabiner.json'
rtk git diff --check
```

Then inspect the relevant profile and manipulator with `jq`. Check the active profile with:

```bash
rtk karabiner_cli --show-current-profile-name
rtk karabiner_cli --list-connected-devices
```

For a tap/hold layer, use EventViewer's Variables view. The layer variable should become `1` while the layer key is held and return to `0` on release. The keyboard event view may not show the held key because the manipulator consumes it and emits only the variable change.

## Runtime boundary

This skill edits and verifies the repository source only. Do not run the consumer's system switch here. If runtime behavior does not match the source, read `llms.md` for deployment and symlink details, then use the consumer's workflow.

## References

Read [references/karabiner-json.md](references/karabiner-json.md) when exact Karabiner semantics or official examples are needed.
