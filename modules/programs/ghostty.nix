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
      keybind = alt+left=unbind
      keybind = alt+right=unbind
      keybind = alt+up=unbind
      keybind = alt+down=unbind
      keybind = super+enter=unbind
      keybind = super+ctrl+f=unbind
      macos-titlebar-style = hidden
      confirm-close-surface = false
    '';
  };
}
