{
  pkgs,
  lib,
  config,
  coreConfig ? { },
  ...
}:
let
  cfg = config.core.apps.espanso;
  yaml = pkgs.formats.yaml { };
  extraMatchFile = lib.optionalAttrs (cfg.extraMatches != [ ]) {
    "espanso/match/generated.yml".source = yaml.generate "espanso-generated-matches.yml" {
      matches = cfg.extraMatches;
    };
  };
in
{
  options.core.apps.espanso = {
    extraMatches = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = lib.attrByPath [ "apps" "espanso" "extraMatches" ] [ ] coreConfig;
      example = [
        {
          trigger = ";mail";
          replace = "you@example.com";
        }
      ];
      description = "Additional Espanso matches rendered from Nix into a generated YAML file.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isDarwin && cfg.enable) {
      xdg.configFile = {
        "espanso/config/default.yml".source = ../../files/espanso/config/default.yml;
        "espanso/match/base.yml".source = ../../files/espanso/match/base.yml;
      }
      // extraMatchFile;
    })

    (lib.mkIf (pkgs.stdenv.isLinux && cfg.enable) {
      # Avoid parent-directory link conflicts with files created by services.espanso.
      xdg.configFile = {
        "espanso/config/default.yml".source = lib.mkForce ../../files/espanso/config/default.yml;
        "espanso/match/base.yml".source = ../../files/espanso/match/base.yml;
      }
      // extraMatchFile;

      services.espanso = {
        enable = true;
        x11Support = true;
        waylandSupport = true;
      };
    })
  ];
}
