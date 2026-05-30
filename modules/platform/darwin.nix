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

  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.packages = lib.optionals config.core.system.desktop [
      pkgs.macism
    ];
  };
}
