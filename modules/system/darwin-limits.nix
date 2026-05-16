{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.core.system.openFiles;
in
lib.mkIf pkgs.stdenv.isDarwin {
  assertions = [
    {
      assertion = cfg.soft <= cfg.hard;
      message = "core.system.openFiles.soft must be less than or equal to core.system.openFiles.hard.";
    }
  ];

  launchd.daemons.core-open-files-limit = {
    script = ''
      /bin/launchctl limit maxfiles ${toString cfg.soft} ${toString cfg.hard}
    '';
    serviceConfig = {
      RunAtLoad = true;
      LaunchOnlyOnce = true;
      SoftResourceLimits.NumberOfFiles = cfg.soft;
      HardResourceLimits.NumberOfFiles = cfg.hard;
    };
  };

  system.activationScripts.coreOpenFilesLimit.text = ''
    /bin/launchctl limit maxfiles ${toString cfg.soft} ${toString cfg.hard}
  '';
}
