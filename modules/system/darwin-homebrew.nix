{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf (pkgs.stdenv.isDarwin && config.core.brew.enable) {
    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = lib.mkDefault true;
        upgrade = lib.mkDefault true;
        cleanup = lib.mkDefault "none";
      };
      taps = config.core.brew.resolved.taps;
      brews = config.core.brew.resolved.brews;
      casks = config.core.brew.resolved.casks;
      masApps = config.core.brew.resolved.masApps;
      extraConfig = config.core.brew.resolved.extraConfig;
    };
  };
}
