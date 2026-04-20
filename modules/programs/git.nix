{ ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      init.defaultBranch = "main";
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
  ];
}
