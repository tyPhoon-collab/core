{ pkgs, lib, features, ... }:
lib.mkIf (pkgs.stdenv.isDarwin && features.desktop) {
  xdg.configFile."karabiner/karabiner.json".source = ../../files/karabiner/karabiner.json;
}