{ hunk, ... }:
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
}
