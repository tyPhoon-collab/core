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
    };
  };

  programs.lazygit.enable = true;
  programs.gh.enable = true;

  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = "function() Snacks.lazygit() end";
      options.desc = "Lazygit";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action.__raw = "function() Snacks.picker.git_status() end";
      options.desc = "Git Status";
    }
    {
      mode = "n";
      key = "<leader>gd";
      action.__raw = "function() Snacks.picker.git_diff() end";
      options.desc = "Git Diff Hunks";
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
