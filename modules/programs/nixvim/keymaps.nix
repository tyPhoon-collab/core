{
  ...
}:
{
  programs.nixvim.keymaps = [
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd>w<CR>";
      options.desc = "Save";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>q<CR>";
      options.desc = "Quit";
    }
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>qa!<CR>";
      options.desc = "Force Quit All";
    }
    {
      mode = "n";
      key = "U";
      action = "<C-r>";
      options.desc = "Redo";
    }
    {
      mode = "n";
      key = "<C-d>";
      action = "<C-d>zz";
      options.desc = "Scroll Down";
    }
    {
      mode = "n";
      key = "<C-u>";
      action = "<C-u>zz";
      options.desc = "Scroll Up";
    }
    {
      mode = "n";
      key = "n";
      action.__raw = ''
        function()
          vim.cmd.normal({ "n", bang = true })
          vim.cmd.normal({ "zz", bang = true })
          vim.cmd.normal({ "zv", bang = true })
        end
      '';
      options.desc = "Next Search Result";
    }
    {
      mode = "n";
      key = "N";
      action.__raw = ''
        function()
          vim.cmd.normal({ "N", bang = true })
          vim.cmd.normal({ "zz", bang = true })
          vim.cmd.normal({ "zv", bang = true })
        end
      '';
      options.desc = "Prev Search Result";
    }
    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
      options.desc = "Join Lines";
    }
    {
      mode = "x";
      key = "J";
      action = ":move '>+1<CR>gv=gv";
      options.desc = "Move Selection Down";
    }
    {
      mode = "x";
      key = "K";
      action = ":move '<-2<CR>gv=gv";
      options.desc = "Move Selection Up";
    }
    {
      mode = "n";
      key = "Q";
      action = "<nop>";
      options.desc = "Disable Ex Mode";
    }
    {
      mode = "i";
      key = "tn";
      action = "<Esc>";
      options.desc = "Exit Insert Mode";
    }
    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>move .+1<CR>==";
      options.desc = "Move Line Down";
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>move .-2<CR>==";
      options.desc = "Move Line Up";
    }
    {
      mode = "i";
      key = "<A-j>";
      action = "<Esc><cmd>move .+1<CR>==gi";
      options.desc = "Move Line Down";
    }
    {
      mode = "i";
      key = "<A-k>";
      action = "<Esc><cmd>move .-2<CR>==gi";
      options.desc = "Move Line Up";
    }
    {
      mode = "t";
      key = "tn";
      action = "<C-\\><C-n>";
      options.desc = "Exit Terminal Mode";
    }
    {
      mode = "n";
      key = "<leader>e";
      action.__raw = "function() Snacks.explorer() end";
      options.desc = "Explorer";
    }
    {
      mode = "n";
      key = "<leader>ff";
      action.__raw = "function() Snacks.picker.files() end";
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action.__raw = "function() Snacks.picker.grep() end";
      options.desc = "Live Grep";
    }
    {
      mode = "n";
      key = "<leader>,";
      action.__raw = "function() Snacks.picker.buffers() end";
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action.__raw = "function() Snacks.picker.help() end";
      options.desc = "Help Tags";
    }
    {
      mode = "n";
      key = "<leader><leader>";
      action.__raw = "function() Snacks.picker.files({ hidden = true, ignored = true }) end";
      options.desc = "Find Files";
    }
    {
      mode = "n";
      key = "<leader>/";
      action.__raw = "function() Snacks.picker.grep() end";
      options.desc = "Live Grep";
    }
    {
      mode = "n";
      key = "<leader>un";
      action.__raw = "function() Snacks.picker.notifications() end";
      options.desc = "Notification History";
    }
    {
      mode = "n";
      key = "<leader>uw";
      action.__raw = ''function() Snacks.toggle.option("wrap", { name = "Wrap" }):toggle() end'';
      options.desc = "Toggle Wrap";
    }
    {
      mode = "n";
      key = "<leader>uc";
      action = "<cmd>TSContext toggle<CR>";
      options.desc = "Toggle Treesitter Context";
    }
    {
      mode = "n";
      key = "<leader>ul";
      action.__raw = ''function() Snacks.toggle.option("relativenumber", { name = "Relative Line Number" }):toggle() end'';
      options.desc = "Toggle Relative Line Number";
    }
    {
      mode = "n";
      key = "<leader>t";
      action.__raw = "function() Snacks.terminal() end";
      options.desc = "Toggle Terminal";
    }
    {
      mode = "n";
      key = "<leader>z";
      action.__raw = "function() Snacks.zen.zoom() end";
      options.desc = "Zoom Window";
    }
    {
      mode = "t";
      key = "<A-Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit Terminal Mode";
    }
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<CR>";
      options.desc = "Prev Buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<CR>";
      options.desc = "Next Buffer";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash Treesitter";
    }
    {
      mode = "n";
      key = "<leader>sw";
      action.__raw = "function() Snacks.picker.grep_word() end";
      options.desc = "Search Current Word";
    }
    {
      mode = "n";
      key = "<leader>st";
      action.__raw = "function() Snacks.picker.todo_comments() end";
      options.desc = "Todo Comments";
    }
    {
      mode = "n";
      key = "<leader>sd";
      action.__raw = "function() Snacks.picker.diagnostics() end";
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>sD";
      action.__raw = "function() Snacks.picker.diagnostics_buffer() end";
      options.desc = "Buffer Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer Diagnostics";
    }
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
    {
      mode = "n";
      key = "<leader>hb";
      action.__raw = "function() require(\"gitsigns\").blame_line() end";
      options.desc = "Blame Line";
    }
    {
      mode = "n";
      key = "<leader>y";
      action = "<cmd>Yazi<cr>";
      options.desc = "Yazi at File";
    }
    {
      mode = "n";
      key = "<leader>n";
      action = "<cmd>Yazi toggle<cr>";
      options.desc = "Resume Yazi";
    }
    {
      mode = "n";
      key = "<leader>jj";
      action = "<cmd>LazyJJ<CR>";
      options.desc = "LazyJJ";
    }
  ];
}
