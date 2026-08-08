# Karabiner JSON reference

## Repository locations

- Source of truth: `files/karabiner/karabiner.json`
- Home Manager deployment: `modules/programs/karabiner.nix`
- Runtime contract and symlink pitfall: `llms.md`
- Consumer integration: `llms.md` and the consumer repository

## Important semantics

- `from.key_code` matches the physical key event. Layout remaps do not turn a later `from.key_code` into the resulting character.
- Rule and manipulator order matters. Put a layer's physical-key interceptors before an unconditional layout rule.
- A variable layer uses `set_variable` and `variable_if`. Undefined variables behave as `0`.
- `to_if_alone` is emitted on release and is canceled by another event while the source key is held.
- A `from` without `modifiers` matches only an event without modifiers. `optional: ["any"]` broadens the match and can capture native shortcuts.
- `software_function.open_application` is the native app-launch action. Prefer bundle identifiers over `shell_command` + `open -a`.

## Official documentation

- [Manipulator definition](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/)
- [From modifiers](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/from/modifiers/)
- [Set variable](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to/set-variable/)
- [To if alone](https://karabiner-elements.pqrs.org/docs/json/complex-modifications-manipulator-definition/to-if-alone/)
- [App launcher example](https://karabiner-elements.pqrs.org/docs/json/expert-complex-modifications-examples/letter-key-holding-modifier/)

## Debug sequence

1. Run `jq empty` and `karabiner_cli --lint-complex-modifications`.
2. Confirm `karabiner_cli --show-current-profile-name` matches the edited profile.
3. Check the layer variable in EventViewer while holding the layer key.
4. If the variable is `1` but the action misses, inspect the action key's physical `key_code` against the active layout rule.
