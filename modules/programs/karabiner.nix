{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.core.apps.karabiner;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."karabiner/karabiner.json".source = ../../files/karabiner/karabiner.json;
  };
}
