{ pkgs, ... }:
let
  leafTab = pkgs.writeShellApplication {
    name = "leaf-tab";
    runtimeInputs = with pkgs; [
      coreutils
      git
      jq
      zellij
    ];
    text = builtins.readFile ../../files/bin/leaf-tab;
  };
in
{
  xdg.configFile = {
    "leaf/config.toml" = {
      source = ../../files/leaf/config.toml;
      force = true;
    };
    "leaf/theme/gruvbox.toml" = {
      source = ../../files/leaf/theme/gruvbox.toml;
      force = true;
    };
  };

  home.packages = [ leafTab ];
}
