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
    ./modules/programs/jujutsu.nix
    ./modules/programs/yazi.nix
    ./modules/programs/nixvim.nix
    ./modules/programs/wezterm.nix
    ./modules/platform/entrypoint.nix
  ];

  home.file.".config/nushell/aliases/git-aliases.nu".source = ./files/nushell/git-aliases.nu;
  home.file.".config/nushell/aliases/original-aliases.nu".source =
    ./files/nushell/original-aliases.nu;

  home.packages =
    with pkgs;
    [
      home-manager
      nix-output-monitor
      nvd
      gdu
      procs
      rsync
    ]
    ++ lib.optionals config.core.system.fonts [
      nerd-fonts.hack
    ]
    ++ lib.optionals config.core.system.extended [
      ffmpeg
      nixfmt
    ];

  programs.bottom.enable = true;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
  };

  fonts.fontconfig.enable = config.core.system.fonts;

  home.username = username;
  home.homeDirectory = homeDirectory;

  home.stateVersion = "25.11";
}
