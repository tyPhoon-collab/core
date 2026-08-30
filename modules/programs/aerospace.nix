{
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
      monitor = "1";
    };
    "2" = {
      enable = true;
      monitor = "1";
    };
    "3" = {
      enable = true;
      monitor = "1";
    };
    "4" = {
      enable = true;
      monitor = "1";
    };
    "5" = {
      enable = true;
      monitor = [
        "3"
        "1"
      ];
    };
    "6" = {
      enable = true;
      monitor = [
        "3"
        "2"
      ];
    };
    "7" = {
      enable = true;
      monitor = "2";
    };
    "8" = {
      enable = true;
      monitor = "2";
    };
    "9" = {
      enable = true;
      monitor = "2";
    };
    "0" = {
      enable = true;
      monitor = "2";
    };
    D = {
      enable = true;
      monitor = "2";
      appIds = [ "com.hnc.Discord" ];
    };
    M = {
      enable = true;
      monitor = "1";
      appIds = [ "com.apple.Music" ];
    };
    O = {
      enable = true;
      monitor = "2";
      appIds = [ "md.obsidian" ];
    };
    T = {
      enable = true;
      monitor = "1";
      appIds = [ "com.mitchellh.ghostty" ];
    };
    W = {
      enable = true;
      monitor = "1";
      appIds = [ "dev.nekonata.denbrowser" ];
    };
  };

  workspaceEnabled =
    workspace: builtins.hasAttr workspace cfg.workspaces && cfg.workspaces.${workspace}.enable;

  workspaceNames = lib.filter workspaceEnabled (lib.attrNames cfg.workspaces);

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
        monitors = if builtins.isList monitor then monitor else [ monitor ];
        renderedMonitors =
          if builtins.length monitors == 1 then
            ''"${builtins.head monitors}"''
          else
            "[${lib.concatMapStringsSep ", " (monitor: ''"${monitor}"'') monitors}]";
      in
      ''"${workspace}" = ${renderedMonitors}''
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
              type = lib.types.oneOf [
                lib.types.str
                (lib.types.listOf lib.types.str)
              ];
              default = "1";
              example = [
                "3"
                "1"
              ];
              description = "Monitor pattern, or ordered monitor patterns for workspace-to-monitor-force-assignment; first matching pattern wins.";
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
