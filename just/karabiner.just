# Run all Karabiner checks
check: lint check-simultaneous

# Lint all Karabiner complex modifications
[no-cd]
lint:
    @jq empty files/karabiner/karabiner.json
    @if command -v karabiner_cli >/dev/null 2>&1; then \
      jq '{title: "check", rules: [.profiles[].complex_modifications.rules[]?]}' files/karabiner/karabiner.json | karabiner_cli --lint-complex-modifications /dev/stdin; \
    else \
      echo "karabiner_cli not found; skipped complex modifications lint"; \
    fi

# Check for duplicate simultaneous chords across all rules
[no-cd]
check-simultaneous:
    jq -e '[.profiles[].complex_modifications.rules[]?.manipulators[]? | select(.from.simultaneous) | {keys: (.from.simultaneous | map(.key_code) | sort | join("+")), cond: (.conditions // [])}] | length == (unique | length)' files/karabiner/karabiner.json >/dev/null
