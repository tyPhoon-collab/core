{ config, lib, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user =
        lib.optionalAttrs (config.core.identity.name != null) {
          name = config.core.identity.name;
        }
        // lib.optionalAttrs (config.core.identity.email != null) {
          email = config.core.identity.email;
        };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      merge.conflictStyle = "zdiff3";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      dark = true;
      syntax-theme = "gruvbox-dark";
      line-numbers = true;
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        pagers = [
          {
            pager = "${lib.getExe config.programs.delta.package} --no-gitconfig --dark --syntax-theme=gruvbox-dark --paging=never --hyperlinks --hyperlinks-file-link-format=\"lazygit-edit://{path}:{line}\"";
          }
        ];
      };
    };
  };

  programs.gh.enable = true;

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>g";
      action.__raw = "function() Snacks.lazygit() end";
      options.desc = "Lazygit";
    }
    {
      mode = "n";
      key = "]c";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            require("gitsigns").nav_hunk("next")
          end
        end
      '';
      options.desc = "Next Hunk";
    }
    {
      mode = "n";
      key = "[c";
      action.__raw = ''
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            require("gitsigns").nav_hunk("prev")
          end
        end
      '';
      options.desc = "Prev Hunk";
    }
    {
      mode = "n";
      key = "<leader>hs";
      action.__raw = "function() require(\"gitsigns\").stage_hunk() end";
      options.desc = "Stage Hunk";
    }
    {
      mode = "n";
      key = "<leader>hr";
      action.__raw = "function() require(\"gitsigns\").reset_hunk() end";
      options.desc = "Reset Hunk";
    }
    {
      mode = "n";
      key = "<leader>hp";
      action.__raw = "function() require(\"gitsigns\").preview_hunk() end";
      options.desc = "Preview Hunk";
    }
    {
      mode = "n";
      key = "<leader>hi";
      action.__raw = "function() require(\"gitsigns\").preview_hunk_inline() end";
      options.desc = "Preview Hunk Inline";
    }
  ];
}
