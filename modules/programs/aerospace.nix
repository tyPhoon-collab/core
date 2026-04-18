{ pkgs, lib, features, ... }:
lib.mkIf (pkgs.stdenv.isDarwin && features.desktop) {
  xdg.configFile."aerospace".source = ../../files/aerospace;
}