mod karabiner 'just/karabiner.just'
mod nix 'just/nix.just'

# List available recipes
default:
    @just --list --list-submodules

# Run all verification checks
check: karabiner::check nix::check
