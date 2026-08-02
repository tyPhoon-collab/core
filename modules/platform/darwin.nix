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

    # Nix Git ships a Darwin system config with osxkeychain enabled. Reset it
    # so consumers can choose their credential transport declaratively.
    programs.git.settings.credential.helper = [ "" ];
  };
}
