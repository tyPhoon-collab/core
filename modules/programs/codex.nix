{
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    home.file.".codex/hooks.json".source = ../../files/codex/hooks.json;
  };
}
