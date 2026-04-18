{
  config,
  pkgs,
  lib,
  features,
  ...
}:
let
  path = "/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin";
  isDesktop = features.desktop;
in
lib.mkIf pkgs.stdenv.isLinux {
  systemd.user = {
    sessionVariables.PATH = path;
    # On Linux, nh-clean systemd service cannot find nix-related binaries
    services.nh-clean.Service.Environment = "PATH=${path}";
  };

  home.packages = lib.optionals isDesktop (
    with pkgs;
    [
      kitty
      wezterm
      alacritty
      fuzzel
      waybar
      obsidian
    ]
  );

  programs.firefox.enable = isDesktop;
}