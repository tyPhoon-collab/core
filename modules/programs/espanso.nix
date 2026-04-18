{
  pkgs,
  lib,
  features,
  ...
}:
let
  isDesktop = features.desktop;
in
lib.mkMerge [
  (lib.mkIf (pkgs.stdenv.isDarwin && isDesktop) {
    xdg.configFile."espanso/config/default.yml".source = ../../files/espanso/config/default.yml;
    xdg.configFile."espanso/match/base.yml".source = ../../files/espanso/match/base.yml;
  })

  (lib.mkIf (pkgs.stdenv.isLinux && isDesktop) {
    # Avoid parent-directory link conflicts with files created by services.espanso.
    xdg.configFile."espanso/config/default.yml".source =
      lib.mkForce ../../files/espanso/config/default.yml;
    xdg.configFile."espanso/match/base.yml".source = ../../files/espanso/match/base.yml;

    services.espanso = {
      enable = true;
      x11Support = true;
      waylandSupport = true;
    };
  })
]