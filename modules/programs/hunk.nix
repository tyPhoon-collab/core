{ hunk, pkgs, ... }:
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
  imports = [ hunk.homeManagerModules.default ];

  programs.hunk = {
    enable = true;
    settings = {
      theme = "gruvbox-dark-hard";
      menu_bar = true;
      wrap_lines = true;
      watch = true;
      agent_notes = true;
    };
  };

  home.packages = [ hunkTab ];
}
