{
  lib,
  nixvim,
  pkgs,
  ...
}:
{
  imports = [
    nixvim.homeModules.nixvim
    ./keymaps.nix
    ./plugins.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = false;
    withPerl = false;
    withPython3 = false;
    withRuby = false;

    opts = {
      number = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      autoindent = true;
      wrap = true;
      linebreak = true;
      clipboard = "unnamedplus";
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      updatetime = 1000;
      timeoutlen = 300;
      confirm = true;
      splitbelow = true;
      splitright = true;
      undofile = true;
      breakindent = true;
      showmode = false;
      completeopt = "menuone,noselect,popup";
      pumborder = "rounded";
      winborder = "rounded";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
      clipboard = lib.mkIf (!pkgs.stdenv.isDarwin) "osc52";

      loaded_netrw = 1;
      loaded_netrwPlugin = 1;
    };

    extraConfigLua = ''
      local ime_group = vim.api.nvim_create_augroup("macos-ime-reset", { clear = true })
      local autoread_group = vim.api.nvim_create_augroup("autoread-checktime", { clear = true })

      local function to_eisuu()
        if vim.fn.executable("macism") == 1 then
          vim.fn.jobstart({ "macism", "com.apple.keylayout.ABC" }, { detach = true })
        end
      end

      local function to_eisuu_unless_insert()
        if not vim.tbl_contains({ "i", "ic", "ix" }, vim.fn.mode()) then
          to_eisuu()
        end
      end

      vim.api.nvim_create_autocmd({ "InsertLeave", "TermLeave" }, {
        group = ime_group,
        callback = to_eisuu,
      })

      vim.api.nvim_create_autocmd("CmdlineEnter", {
        group = ime_group,
        callback = to_eisuu,
      })

      vim.api.nvim_create_autocmd("FocusGained", {
        group = ime_group,
        callback = to_eisuu_unless_insert,
      })

      vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "CursorHold", "CursorHoldI" }, {
        group = autoread_group,
        callback = function()
          if vim.fn.mode() ~= "c" then
            vim.cmd("checktime")
          end
        end,
      })
    '';

    highlightOverride = {
      TreesitterContextBottom.underline = true;
      TreesitterContextLineNumberBottom.underline = true;
    };

    colorschemes.gruvbox = {
      enable = true;
      settings = {
        contrast = "dark";
        transparent_mode = true;
      };
    };
  };
}
