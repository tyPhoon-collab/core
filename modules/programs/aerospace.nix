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
  fromPath = path: fallback: lib.attrByPath path fallback coreConfig;

  defaultFloatingAppIds = [
    "com.apple.systempreferences"
    "com.apple.finder"
    "io.mpv"
  ];

  defaultWorkspaces = {
    "1" = {
      enable = true;
      monitor = "main";
    };
    "2" = {
      enable = true;
      monitor = "main";
    };
    "3" = {
      enable = true;
      monitor = "main";
    };
    "4" = {
      enable = true;
      monitor = "main";
    };
    "5" = {
      enable = true;
      monitor = "main";
    };
    "6" = {
      enable = true;
      monitor = "secondary";
    };
    "7" = {
      enable = true;
      monitor = "secondary";
    };
    "8" = {
      enable = true;
      monitor = "secondary";
    };
    "9" = {
      enable = true;
      monitor = "secondary";
    };
    "0" = {
      enable = true;
      monitor = "secondary";
    };
    B = {
      enable = true;
      monitor = "main";
    };
    D = {
      enable = true;
      monitor = "secondary";
      appIds = [ "com.hnc.Discord" ];
    };
    M = {
      enable = true;
      monitor = "main";
      appIds = [ "com.apple.Music" ];
    };
    O = {
      enable = true;
      monitor = "secondary";
      appIds = [ "md.obsidian" ];
    };
    T = {
      enable = true;
      monitor = "main";
      appIds = [ "com.github.wez.wezterm" ];
    };
  };

  workspaceOrder = [
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "0"
    "B"
    "D"
    "M"
    "O"
    "S"
    "T"
  ];

  workspaceEnabled =
    workspace: builtins.hasAttr workspace cfg.workspaces && cfg.workspaces.${workspace}.enable;

  workspaceNames = lib.filter workspaceEnabled (
    lib.unique (workspaceOrder ++ lib.attrNames cfg.workspaces)
  );

  workspaceKey = workspace: lib.toLower workspace;

  renderedPersistentWorkspaces = ''
    persistent-workspaces = [
    ${lib.concatMapStringsSep "\n" (workspace: ''"${workspace}",'') workspaceNames}
    ]'';

  renderedWorkspaceBindings = lib.concatMapStringsSep "\n" (
    workspace:
    let
      key = workspaceKey workspace;
    in
    ''
      alt-${key} = "workspace ${workspace}"
      alt-shift-${key} = "move-node-to-workspace ${workspace}"''
  ) workspaceNames;

  renderedWorkspaceMonitorAssignments = ''
    [workspace-to-monitor-force-assignment]
    ${lib.concatMapStringsSep "\n" (
      workspace:
      let
        monitor = cfg.workspaces.${workspace}.monitor;
      in
      ''"${workspace}" = "${monitor}"''
    ) workspaceNames}'';

  workspaceAwareToml =
    builtins.replaceStrings
      [
        "# __CORE_AEROSPACE_PERSISTENT_WORKSPACES__"
        "# __CORE_AEROSPACE_WORKSPACE_BINDINGS__"
        "# __CORE_AEROSPACE_MONITOR_ASSIGNMENTS__"
        "# __CORE_AEROSPACE_FLOATING_APP_RULES__"
      ]
      [
        renderedPersistentWorkspaces
        renderedWorkspaceBindings
        renderedWorkspaceMonitorAssignments
        renderedFloatingAppRules
      ]
      baseToml;

  appWorkspaceRules = lib.concatMap (
    workspace:
    map (appId: {
      inherit appId workspace;
    }) cfg.workspaces.${workspace}.appIds
  ) workspaceNames;

  renderedFloatingAppRules = lib.concatMapStringsSep "\n\n" (appId: ''
    [[on-window-detected]]
    if.app-id = "${appId}"
    run = "layout floating"
  '') cfg.floatingAppIds;

  renderedWorkspaceAppRules = lib.concatMapStringsSep "\n\n" (rule: ''
    [[on-window-detected]]
    if.app-id = "${rule.appId}"
    run = "move-node-to-workspace ${rule.workspace}"
  '') appWorkspaceRules;

  renderedConfig =
    workspaceAwareToml
    + lib.optionalString (renderedWorkspaceAppRules != "") (
      "\n\n# Appended by core.apps.aerospace.workspaces.*.appIds\n" + renderedWorkspaceAppRules + "\n"
    );
in
{
  options.core.apps.aerospace = {
    floatingAppIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = lib.unique (
        defaultFloatingAppIds ++ fromPath [ "apps" "aerospace" "floatingAppIds" ] [ ]
      );
      example = [ "com.apple.Preview" ];
      description = "Application IDs configured as floating windows.";
    };

    workspaces = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              example = true;
              description = "Whether this workspace should be generated.";
            };

            monitor = lib.mkOption {
              type = lib.types.str;
              default = "main";
              example = "secondary";
              description = "Monitor assignment for workspace-to-monitor-force-assignment.";
            };

            appIds = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              example = [ "com.tinyspeck.slackmacgap" ];
              description = "Application IDs moved to this workspace by on-window-detected.";
            };
          };
        }
      );
      default = lib.recursiveUpdate defaultWorkspaces (fromPath [ "apps" "aerospace" "workspaces" ] { });
      description = ''
        Workspaces managed by core. Each workspace gets persistent workspace,
        alt-<workspace> and alt-shift-<workspace> bindings, monitor assignment,
        and app-id based window rules when enabled.
      '';
    };
  };

  config = {
    xdg.configFile = lib.mkIf cfg.enable {
      "aerospace/aerospace.toml".text = renderedConfig;
    };
  };
}
