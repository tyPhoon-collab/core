# core implementation notes

This file is the implementation-oriented reference for humans and AI agents working with this repository. `README.md` is intentionally short and human-facing; this file is the detailed source of truth.

## Repository shape

- `home.nix`
  Home Manager entrypoint. Imports `modules/core.nix` plus shell, program, and platform modules.
- `modules/core.nix`
  Defines the `core.*` options and resolves `core.brew.resolved`.
- `modules/programs/*`
  Program modules for Git, Jujutsu, AeroSpace, Espanso, Ghostty, Karabiner, Yazi, Nixvim, and related tooling.
- `modules/platform/*`
  Platform-specific branching for Darwin, Linux, and WSL.
- `modules/system/darwin-defaults.nix`
  nix-darwin `system.defaults` plus `programs.zsh.enable`.
- `modules/system/darwin-limits.nix`
  Applies `launchctl limit maxfiles` from `core.system.openFiles.*`.
- `lib/home-manager.nix`
  Shared defaults for Home Manager integration.

At the moment, `modules/programs/wezterm.nix` and `files/wezterm/` still exist in the tree, but `home.nix` does not import them. Treat WezTerm as inactive, not as part of the supported public surface.

## Runtime contract

`home.nix` expects at least these arguments:

- `username`
- `homeDirectory`
- `nixvim`
- `yaziPlugins`
- `coreConfig`

`coreConfig` is the raw input passed by the consumer. After module evaluation, normalized state is exposed through `config.core`. Consumers generally write `coreConfig`; modules inside this repo should read `config.core`.

## Public config surface

The actual public surface currently consumed by `modules/core.nix` and the program modules is:

- `core.identity.name`
- `core.identity.email`
- `core.system.desktop`
- `core.system.fonts`
- `core.system.extended`
- `core.system.devLevel`
- `core.system.wsl`
- `core.system.openFiles.soft`
- `core.system.openFiles.hard`
- `core.apps.aerospace.enable`
- `core.apps.aerospace.workspaces`
- `core.apps.aerospace.floatingAppIds`
- `core.apps.espanso.enable`
- `core.apps.espanso.extraMatches`
- `core.apps.ghostty.enable`
- `core.apps.karabiner.enable`
- `core.shell.nushell.shellAliases`
- `core.brew.enable`
- `core.brew.extraTaps`
- `core.brew.extraBrews`
- `core.brew.extraCasks`
- `core.brew.extraMasApps`
- `core.brew.resolved`

Notes:

- `core.apps.ghostty` and `core.apps.karabiner` currently expose only `enable`.
- `core.shell.nushell` currently exposes only `shellAliases`.
- `core.brew.resolved` is read-only and contains the merged result of the built-in base lists plus consumer `extra*` values.

## Behavior notes by subsystem

### Shell and base tools

- `programs.nushell.enable = true`
- Aliases are merged as `defaultAliases // cfg.shellAliases`
- Enables `direnv`, `zoxide`, `starship`, `carapace`, `mise`, and `zellij`

### Git

- `programs.git.enable = true`
- `programs.git.lfs.enable = true`
- Default settings are `init.defaultBranch = "main"`, `pull.rebase = true`, and `push.autoSetupRemote = true`
- If `config.core.identity.*` is set, those values flow into `programs.git.settings.user.*`
- `programs.lazygit.enable = true`
- `programs.gh.enable = true`

Consumer override example:

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };

  programs.git.settings.pull.rebase = false;
}
```

### Jujutsu

- `programs.jujutsu.enable = true`
- Defines aliases `f` and `p`
- Sets `ui.default-command = "log"`
- Sets `revset-aliases."immutable_heads()" = "builtin_immutable_heads() | present(main) | present(main@origin)"`
- If `config.core.identity.*` is set, those values flow into `programs.jujutsu.settings.user.*`

Consumer override example:

```nix
{
  coreConfig.identity = {
    name = "Your Name";
    email = "you@example.com";
  };

  programs.jujutsu.settings = {
    git.push-bookmark-prefix = "hiroaki/";
    ui.paginate = "auto";
  };
}
```

### AeroSpace

- If `core.apps.aerospace.enable` is true, core generates `xdg.configFile."aerospace/aerospace.toml"`
- The base file is `files/aerospace/aerospace.toml`
- `core.apps.aerospace.workspaces.<name>` defines generated workspaces
- Each workspace supports `enable`, `monitor`, and `appIds`
- Enabled workspaces feed persistent workspaces, `alt-<key>`, `alt-shift-<key>`, monitor assignment, and `on-window-detected` rules
- `core.apps.aerospace.floatingAppIds` appends floating window rules

Consumer override example:

```nix
{
  core.apps.aerospace.workspaces.S = {
    monitor = "secondary";
    appIds = [ "com.tinyspeck.slackmacgap" ];
  };

  core.apps.aerospace.workspaces.B.appIds = [
    "company.thebrowser.dia"
  ];

  core.apps.aerospace.floatingAppIds = [
    "com.apple.Preview"
  ];
}
```

Additional notes:

- `workspaces.<name>` defaults to `enable = true`
- `S` is present in `workspaceOrder` but is not part of the built-in default workspace set
- `appIds` become rules only for enabled workspaces

### Espanso

- If `core.apps.espanso.enable` is true, core installs Espanso config files
- On Darwin, this is only `xdg.configFile`
- On Linux, this also enables `services.espanso`
- If `core.apps.espanso.extraMatches` is non-empty, core generates an additional YAML file

Consumer override example:

```nix
{
  core.apps.espanso.extraMatches = [
    {
      trigger = ";mail";
      replace = "you@example.com";
    }
  ];
}
```

### Ghostty and Karabiner

- `core.apps.ghostty.enable` controls installation of the Ghostty config file
- `core.apps.karabiner.enable` controls installation of the Karabiner config file
- There are currently no additional public options for either module

### Homebrew

`modules/core.nix` defines a built-in Darwin desktop Homebrew base list and resolves these values into `core.brew.resolved`:

- `taps`
- `brews`
- `casks`
- `masApps`

When `core.system.desktop = false`, the default for `core.brew.enable` also becomes `false`, and `core.brew.resolved` becomes empty.

Consumer integration example:

```nix
{
  imports = [
    (inputs.core + /modules/core.nix)
    (inputs.core + /modules/system/darwin-defaults.nix)
    (inputs.core + /modules/system/darwin-limits.nix)
  ];

  homebrew = {
    enable = true;
    taps = config.core.brew.resolved.taps;
    brews = config.core.brew.resolved.brews;
    casks = config.core.brew.resolved.casks;
    masApps = config.core.brew.resolved.masApps;
  };
}
```

## Integration examples

### Standalone Home Manager

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    core = {
      url = "path:/path/to/core";
      flake = false;
    };
    nixvim.url = "github:nix-community/nixvim";
    yazi-plugins = {
      url = "github:yazi-rs/plugins";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, core, ... }:
    let
      system = "x86_64-linux";
      username = "user";
      homeDirectory = "/home/user";
      pkgs = import nixpkgs { inherit system; };
      coreConfig = {
        system.devLevel = 2;
      };
    in
    {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit username homeDirectory core coreConfig;
          nixvim = inputs.nixvim;
          yaziPlugins = inputs.yazi-plugins;
        };
        modules = [
          ({ core, ... }: {
            imports = [ (core + /home.nix) ];
          })
        ];
      };
    };
}
```

### NixOS or nix-darwin with Home Manager

```nix
let
  coreHomeManager = import (core + /lib/home-manager.nix);
in
{
  modules = [
    home-manager.nixosModules.home-manager
    {
      home-manager = coreHomeManager.default // {
        users.${username} = import ./home.nix;
        extraSpecialArgs = {
          inherit username homeDirectory core coreConfig;
          nixvim = inputs.nixvim;
          yaziPlugins = inputs.yazi-plugins;
        };
      };
    }
  ];
}
```

## Consumer alignment

The main consumer at `/Users/hiroaki/.config/dotfiles` currently:

- Imports `modules/core.nix`, `modules/system/darwin-defaults.nix`, and `modules/system/darwin-limits.nix` from `hosts/darwin/default.nix`
- Maps `config.core.brew.resolved` into `homebrew.*`
- Constructs `coreConfig` in `flake.nix` and passes it through `extraSpecialArgs`

Keep the docs aligned with that model: this repository is a reusable source input, not a standalone flake.
