{ pkgs, ... }:
let
  hunkTab = pkgs.writeShellApplication {
    name = "hunk-tab";
    runtimeInputs = with pkgs; [
      coreutils
      git
      jq
      zellij
    ];
    text = builtins.readFile ../../files/bin/hunk-tab;
  };
in
{
  home.packages = [ hunkTab ];

  xdg.configFile."hunk/config.toml".source = ../../files/hunk/config.toml;
}
