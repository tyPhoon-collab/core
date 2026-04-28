{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.core.apps.wezterm;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."wezterm".source = ../../files/wezterm;
  };
}
