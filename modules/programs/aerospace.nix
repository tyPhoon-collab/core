{
  pkgs,
  lib,
  config,
  coreConfig ? { },
  ...
}:
let
  cfg = config.core.apps.aerospace;
  baseToml = builtins.readFile ../../files/aerospace/aerospace.toml;

  extraRules = lib.mapAttrsToList (appId: rule: {
    inherit appId;
    run =
      if rule.workspace != null then "move-node-to-workspace ${rule.workspace}" else "layout floating";
  }) cfg.extraRules;

  appendedRules = lib.concatMapStringsSep "\n\n" (rule: ''
    [[on-window-detected]]
    if.app-id = "${rule.appId}"
    run = "${rule.run}"
  '') extraRules;

  renderedConfig =
    baseToml
    + lib.optionalString (appendedRules != "") (
      "\n\n# Appended by core.apps.aerospace.extraRules\n" + appendedRules + "\n"
    );
in
{
  options.core.apps.aerospace = {
    extraRules = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            workspace = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "B";
              description = "Workspace name for move-node-to-workspace.";
            };

            floating = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
              description = "When true, app window is configured as floating.";
            };
          };
        }
      );
      example = {
        "company.thebrowser.dia" = {
          workspace = "B";
        };
        "com.apple.Preview" = {
          floating = true;
        };
      };
      default = lib.attrByPath [ "apps" "aerospace" "extraRules" ] { } coreConfig;
      description = ''
        Extra app rules keyed by app-id. `workspace` has priority over `floating`.
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = lib.all (rule: rule.workspace != null || rule.floating) (
          builtins.attrValues cfg.extraRules
        );
        message = "core.apps.aerospace.extraRules.<appId> must set at least one of workspace or floating.";
      }
    ];

    xdg.configFile = lib.mkIf cfg.enable {
      "aerospace/aerospace.toml".text = renderedConfig;
    };
  };
}
