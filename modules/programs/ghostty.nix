{
  lib,
  config,
  ...
}:
let
  cfg = config.core.apps.ghostty;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."ghostty/config.ghostty".text = ''
      theme = Catppuccin Mocha
      font-family = "Hack Nerd Font Mono"
      font-family = "Hiragino Sans W4"
      macos-option-as-alt = left
      macos-titlebar-style = hidden
      confirm-close-surface = false
    '';
  };
}
