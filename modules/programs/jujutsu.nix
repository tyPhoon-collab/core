{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    lazyjj
  ];

  programs.jujutsu = {
    enable = true;

    settings = {
      aliases = {
        f = [
          "git"
          "fetch"
        ];
        p = [
          "git"
          "push"
        ];
      };
      user =
        lib.optionalAttrs (config.core.identity.name != null) {
          name = config.core.identity.name;
        }
        // lib.optionalAttrs (config.core.identity.email != null) {
          email = config.core.identity.email;
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

    extraConfigLuaPost = ''
      require("lazyjj").setup({
        mapping = false,
      })
    '';

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
