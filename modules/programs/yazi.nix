{
  yaziPlugins,
  pkgs,
  lib,
  config,
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
          on = [
            ","
            "d"
          ];
          run = "sort --dir-first=no";
          desc = "Files first";
        }
        {
          on = [
            ","
            "D"
          ];
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

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>y";
      action = "<cmd>Yazi<cr>";
      options.desc = "Yazi at File";
    }
    {
      mode = "n";
      key = "<leader>cw";
      action = "<cmd>Yazi cwd<cr>";
      options.desc = "Yazi in CWD";
    }
    {
      mode = "n";
      key = "<leader>n";
      action = "<cmd>Yazi toggle<cr>";
      options.desc = "Resume Yazi";
    }
  ];

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
    ++ lib.optionals config.core.system.extended [
      poppler
      resvg
      imagemagick
      # (mpv.override { youtubeSupport = false; })
    ];
}
