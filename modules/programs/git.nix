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
  ];
}
