{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lazyjj
  ];

  programs.jujutsu = {
    enable = true;

    settings = {
      aliases = {
        f = [ "git" "fetch" ];
        p = [ "git" "push" ];
      };
      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | present(main) | present(main@origin)";
      };
      ui.default-command = "log";
    };
  };

  programs.nixvim = {
    extraPackages = with pkgs; [
      lazyjj
    ];

    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim
      lazyjj-nvim
    ];

    keymaps = [
      {
        mode = "n";
        key = "<leader>jj";
        action = "<cmd>LazyJJ<CR>";
        options.desc = "LazyJJ";
      }
    ];
  };
}
