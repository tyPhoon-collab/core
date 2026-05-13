{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/aerospace.nix
    ../programs/karabiner.nix
  ];

  home.packages = lib.optionals config.core.system.desktop [
    pkgs.macism
  ];
}
