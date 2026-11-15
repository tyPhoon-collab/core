# Run all Nix static checks
check: fmt-check deadnix statix

# Format Nix files (defaults to all tracked files)
[no-cd]
fmt *FILES:
    ulimit -n 4096 && if [ -z "{{ FILES }}" ]; then git ls-files -z '*.nix' | xargs -0 nix run nixpkgs#nixfmt --; else nix run nixpkgs#nixfmt -- {{ FILES }}; fi

# Check Nix formatting without modifying files
[no-cd]
fmt-check:
    ulimit -n 4096 && git ls-files -z '*.nix' | xargs -0 nix run nixpkgs#nixfmt -- --check

# Check for unused Nix bindings
[no-cd]
deadnix:
    ulimit -n 4096 && nix run nixpkgs#deadnix -- --fail .

# Lint Nix files for anti-patterns
[no-cd]
statix:
    ulimit -n 4096 && nix run nixpkgs#statix -- check .
