{
  pkgs,
  lib,
  features,
  ...
}:
lib.mkIf (features.desktop && (pkgs.stdenv.isDarwin || pkgs.stdenv.isLinux)) {
  xdg.configFile."wezterm".source = ../../files/wezterm;
}