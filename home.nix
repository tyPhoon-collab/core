{
  config,
  pkgs,
  lib,
  username,
  homeDirectory,
  ...
}:
{
  imports = [
    ./modules/core.nix
    ./modules/shell/shell.nix
    ./modules/programs/espanso.nix
    ./modules/programs/git.nix
    ./modules/programs/ghostty.nix
    ./modules/programs/hunk.nix
    ./modules/programs/leaf.nix
    ./modules/programs/yazi.nix
    ./modules/programs/zellij.nix
    ./modules/programs/nixvim
    ./modules/platform/entrypoint.nix
  ];

  home = {
    packages =
      with pkgs;
      [
        home-manager
        nix-output-monitor
        nu_scripts
        nvd
        difftastic
        eza
        gdu
        procs
        rsync
      ]
      ++ lib.optionals config.core.system.fonts [
        maple-mono.NF-CN-unhinted
        nerd-fonts.hack
      ]
      ++ lib.optionals config.core.system.extended [
        ffmpeg
        nixfmt
      ];

    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs = {
    bottom.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 10";
    };

  };

  fonts.fontconfig.enable = config.core.system.fonts;
}
