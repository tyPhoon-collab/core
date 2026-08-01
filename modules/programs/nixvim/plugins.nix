{
  lib,
  pkgs,
  config,
  ...
}:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      lazyjj
    ];

    extraPlugins = with pkgs.vimPlugins; [
      cutlass-nvim
      mini-nvim
      plenary-nvim
      lazyjj-nvim
    ];

    extraConfigLuaPost = ''
      require("cutlass").setup({
        exclude = { "ns", "nS", "xs", "xS", "os", "oS", "nd", "nD", "xd", "xD" },
      })

      require("lazyjj").setup({
        mapping = false,
      })

      require("mini.ai").setup()
      require("mini.bracketed").setup()
      require("mini.cursorword").setup()
      require("mini.files").setup({
        windows = {
          preview = true,
        },
      })

      require("mini.indentscope").setup()
      require("mini.jump2d").setup({
        mappings = {
          start_jumping = "",
        },
      })
      require("mini.notify").setup()
      require("mini.pairs").setup()
      require("mini.pick").setup()
      require("mini.statusline").setup()
      local mode_colors = {
        Normal = { fg = "#ebdbb2", bg = "#3c3836" },
        Insert = { fg = "#ebdbb2", bg = "#458588" },
        Visual = { fg = "#282828", bg = "#b8bb26" },
        Replace = { fg = "#ebdbb2", bg = "#cc241d" },
        Command = { fg = "#282828", bg = "#fabd2f" },
        Other = { fg = "#ebdbb2", bg = "#8f3f71" },
      }
      for mode, colors in pairs(mode_colors) do
        vim.api.nvim_set_hl(0, "MiniStatuslineMode" .. mode, {
          fg = colors.fg,
          bg = colors.bg,
          bold = true,
        })
      end
      require("mini.surround").setup()
      require("mini.tabline").setup()
    '';

    plugins =
      {
        lsp = {
          enable = config.core.system.devLevel >= 1;
          servers =
            (lib.genAttrs [ "jsonls" "lua_ls" "nixd" "markdown_oxide" ] (name: {
              enable = config.core.system.devLevel >= 1;
            }))
            // (lib.genAttrs [ "bashls" "ts_ls" "pyright" "yamlls" "gopls" ] (name: {
              enable = config.core.system.devLevel >= 2;
            }))
            // {
              kotlin_lsp = {
                enable = config.core.system.devLevel >= 2;
                package = null;
                cmd = [
                  "kotlin-lsp"
                  "--stdio"
                ];
              };
              jdtls = {
                enable = config.core.system.devLevel >= 2;
                packageFallback = true;
              };
              dartls = {
                enable = config.core.system.devLevel >= 2;
                package = null;
              };
              sourcekit = {
                enable = config.core.system.devLevel >= 2;
                package = null;
              };
              rust_analyzer = {
                enable = config.core.system.devLevel >= 2;
                installCargo = false;
                installRustc = false;
              };
            };
          keymaps = {
            silent = true;
            lspBuf.K = "hover";
            diagnostic = {
              "<leader>cd" = "open_float";
              "[d" = "goto_prev";
              "]d" = "goto_next";
            };
            extra = [
              {
                mode = "n";
                key = "<leader>ca";
                action.__raw = "function() vim.lsp.buf.code_action() end";
                options.desc = "Code Action";
              }
              {
                mode = "n";
                key = "gd";
                action.__raw = "function() vim.lsp.buf.definition() end";
                options.desc = "Goto Definition";
              }
              {
                mode = "n";
                key = "grr";
                action.__raw = "function() vim.lsp.buf.references() end";
                options.desc = "References";
              }
              {
                mode = "n";
                key = "gri";
                action.__raw = "function() vim.lsp.buf.implementation() end";
                options.desc = "Goto Implementation";
              }
              {
                mode = "n";
                key = "grt";
                action.__raw = "function() vim.lsp.buf.type_definition() end";
                options.desc = "Goto Type Definition";
              }
            ];
          };
        };

        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            sources = [
              { name = "nvim_lsp"; }
              { name = "path"; }
              { name = "buffer"; }
            ];
            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-e>" = "cmp.mapping.close()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            };
          };
        };

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };

        "treesitter-context".enable = true;

        "smear-cursor" = {
          enable = true;
          settings = {
            smear_insert_mode = true;
            stiffness = 0.8;
            trailing_stiffness = 0.6;
            stiffness_insert_mode = 0.7;
            trailing_stiffness_insert_mode = 0.7;
            damping = 0.95;
            damping_insert_mode = 0.95;
            distance_stop_animating = 0.5;
            hide_target_hack = false;
          };
        };

      }
      // (lib.genAttrs
        [
          "web-devicons"
          "gitsigns"
          "todo-comments"
          "trouble"
          "yazi"
        ]
        (_: {
          enable = true;
        })
      );
  };
}
