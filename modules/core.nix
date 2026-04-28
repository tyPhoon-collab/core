{
  config,
  coreConfig ? { },
  lib,
  pkgs,
  ...
}:
let
  defaultDarwinHomebrew = {
    taps = [
      "FelixKratz/formulae"
    ];

    brews = [
      "borders"
    ];

    casks = [
      "aerospace"
      "espanso"
      "karabiner-elements"
      "wezterm"
    ];

    masApps = { };
  };
  fromPath = path: fallback: lib.attrByPath path fallback coreConfig;
in
{
  options.core = {
    identity = {
      name = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = fromPath [ "identity" "name" ] null;
        description = "Display name shared across developer tools such as Git and Jujutsu.";
      };

      email = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = fromPath [ "identity" "email" ] null;
        description = "Email address shared across developer tools such as Git and Jujutsu.";
      };
    };

    system = {
      desktop = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "system" "desktop" ] false;
        description = "Whether desktop-oriented core settings should be enabled.";
      };

      fonts = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "system" "fonts" ] false;
        description = "Whether font-related core settings should be enabled.";
      };

      extended = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "system" "extended" ] false;
        description = "Whether the extended core toolset should be enabled.";
      };

      devLevel = lib.mkOption {
        type = lib.types.int;
        default = fromPath [ "system" "devLevel" ] 1;
        description = "Core development profile level.";
      };

      wsl = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "system" "wsl" ] false;
        description = "Whether the target environment is WSL.";
      };
    };

    apps = {
      aerospace.enable = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "apps" "aerospace" "enable" ] (
          pkgs.stdenv.isDarwin && config.core.system.desktop
        );
        description = "Whether the core AeroSpace configuration should be installed.";
      };

      espanso.enable = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "apps" "espanso" "enable" ] config.core.system.desktop;
        description = "Whether the core Espanso configuration should be installed.";
      };

      karabiner.enable = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "apps" "karabiner" "enable" ] (
          pkgs.stdenv.isDarwin && config.core.system.desktop
        );
        description = "Whether the core Karabiner configuration should be installed.";
      };

      wezterm.enable = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "apps" "wezterm" "enable" ] (
          config.core.system.desktop && (pkgs.stdenv.isDarwin || pkgs.stdenv.isLinux)
        );
        description = "Whether the core WezTerm configuration should be installed.";
      };
    };

    brew = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = fromPath [ "brew" "enable" ] (pkgs.stdenv.isDarwin && config.core.system.desktop);
        description = "Whether core Homebrew integration should be considered enabled.";
      };

      extraTaps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = fromPath [ "brew" "extraTaps" ] [ ];
        description = "Additional Homebrew taps appended by the consumer.";
      };

      extraBrews = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = fromPath [ "brew" "extraBrews" ] [ ];
        description = "Additional Homebrew formulae appended by the consumer.";
      };

      extraCasks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = fromPath [ "brew" "extraCasks" ] [ ];
        description = "Additional Homebrew casks appended by the consumer.";
      };

      extraMasApps = lib.mkOption {
        type = lib.types.attrsOf lib.types.int;
        default = fromPath [ "brew" "extraMasApps" ] { };
        description = "Additional Mac App Store applications appended by the consumer.";
      };

      resolved = lib.mkOption {
        type = lib.types.attrs;
        readOnly = true;
        description = "Merged Homebrew data resolved from base and extra settings.";
      };
    };
  };

  config.core.brew.resolved =
    if config.core.brew.enable then
      {
        taps = lib.unique (defaultDarwinHomebrew.taps ++ config.core.brew.extraTaps);
        brews = lib.unique (defaultDarwinHomebrew.brews ++ config.core.brew.extraBrews);
        casks = lib.unique (defaultDarwinHomebrew.casks ++ config.core.brew.extraCasks);
        masApps = defaultDarwinHomebrew.masApps // config.core.brew.extraMasApps;
      }
    else
      {
        taps = [ ];
        brews = [ ];
        casks = [ ];
        masApps = { };
      };
}
