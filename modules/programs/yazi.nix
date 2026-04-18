{
  yaziPlugins,
  pkgs,
  lib,
  features,
  ...
}:
{
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    shellWrapperName = "y";
    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
      };
      preview = {
        max_width = 1600;
        max_height = 1600;
      };
    };
    keymap = {
      mgr.prepend_keymap = [
        {
          on = [ "," "d" ];
          run = "sort --dir-first=no";
          desc = "Files first";
        }
        {
          on = [ "," "D" ];
          run = "sort --dir-first";
          desc = "Dirs first";
        }
        {
          on = [ "l" ];
          run = "plugin smart-enter";
          desc = "Enter directory or open file";
        }
        {
          on = [ "<Enter>" ];
          run = "plugin smart-enter";
          desc = "Enter directory or open file";
        }
      ];
    };
    plugins = {
      smart-enter = "${yaziPlugins}/smart-enter.yazi";
    };
  };

  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.fd.enable = true;
  programs.bat.enable = true;
  programs.jq.enable = true;

  home.packages =
    with pkgs;
    [
      file
      p7zip
    ]
    ++ lib.optionals features.extended [
      poppler
      resvg
      imagemagick
      mpv
    ];
}
