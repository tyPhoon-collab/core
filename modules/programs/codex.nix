{
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    xdg.configFile."codex/hooks.json".source = ../../files/codex/hooks.json;
  };
}
