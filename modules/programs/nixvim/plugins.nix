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
    '';

    plugins =
      {
        lsp = {
          enable = config.core.system.devLevel >= 1;
          servers =
            (lib.genAttrs [ "jsonls" "lua_ls" "nixd" "markdown_oxide" ] (name: {
              enable = config.core.system.devLevel >= 1;
            }))
            // (lib.genAttrs [ "bashls" "ts_ls" "pyright" "yamlls" "kotlin_language_server" "gopls" ] (name: {
              enable = config.core.system.devLevel >= 2;
            }))
            // {
              jdtls = {
                enable = config.core.system.devLevel >= 2;
                packageFallback = true;
              };
              dartls = {
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
                action.__raw = "function() Snacks.picker.lsp_definitions() end";
                options.desc = "Goto Definition";
              }
              {
                mode = "n";
                key = "grr";
                action.__raw = "function() Snacks.picker.lsp_references() end";
                options.desc = "References";
              }
              {
                mode = "n";
                key = "gri";
                action.__raw = "function() Snacks.picker.lsp_implementations() end";
                options.desc = "Goto Implementation";
              }
              {
                mode = "n";
                key = "grt";
                action.__raw = "function() Snacks.picker.lsp_type_definitions() end";
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

        snacks = {
          enable = true;
          settings =
            (lib.genAttrs
              [
                "explorer"
                "indent"
                "input"
                "notifier"
                "picker"
                "quickfile"
                "scope"
                "statuscolumn"
                "terminal"
                "toggle"
                "words"
              ]
              (_: {
                enabled = true;
              })
            )
            // {
              dashboard = {
                enabled = true;
                sections = [
                  { section = "header"; }
                  {
                    section = "keys";
                    gap = 1;
                    padding = 1;
                  }
                  {
                    icon = " ";
                    title = "Recent Files";
                    section = "recent_files";
                    indent = 2;
                    padding = 1;
                  }
                  {
                    icon = " ";
                    title = "Projects";
                    section = "projects";
                    indent = 2;
                    padding = 1;
                  }
                  # { section = "startup"; } # lazy.nvim dependency (startup stats) disabled
                ];
              };
              scroll.enabled = false;
              picker.sources.explorer = {
                watch = true;
                git_status = true;
                git_status_open = true;
                git_untracked = true;
              };
              lazygit = {
                # Snacks' default lazygit config injects `os.editPreset = "nvim-remote"`.
                # That path is fragile unless Neovim is started with a stable --listen pipe.
                configure = false;
              };
            };
        };
      }
      // (lib.genAttrs
        [
          "lualine"
          "bufferline"
          "web-devicons"
          "gitsigns"
          "flash"
          "nvim-autopairs"
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
