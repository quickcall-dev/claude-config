-- ============================================
-- MINIMAL NVIM CONFIG
-- ============================================

-- Leader key (space) — set before plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- --------------------------------------------
-- OPTIONS
-- --------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500

-- --------------------------------------------
-- KEYMAPS
-- --------------------------------------------

local map = vim.keymap.set

-- Better escape
map("i", "jk", "<Esc>")

-- Move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Center after scrolling
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Window splits
map("n", "<leader>sv", "<cmd>vsplit<CR>")
map("n", "<leader>sh", "<cmd>split<CR>")

-- Clear search
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- --------------------------------------------
-- BOOTSTRAP LAZY.NVIM
-- --------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --------------------------------------------
-- PLUGINS
-- --------------------------------------------

require("lazy").setup({
  -- Seamless tmux <-> nvim navigation (Ctrl-h/j/k/l)
  { "christoomey/vim-tmux-navigator" },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      local header = {
        type = "text",
        val = "ship it.",
        opts = { position = "center", hl = "QuickHeader" },
      }

      local quick = {
        type = "text",
        val = "quick",
        opts = { position = "center", hl = "QuickTeal" },
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file      Space ff", "<cmd>Telescope find_files<CR>"),
        dashboard.button("g", "  Live grep      Space fg", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
      }

      local set_hl = function()
        vim.api.nvim_set_hl(0, "QuickTeal", { fg = "#2dd4bf", bold = true })
        vim.api.nvim_set_hl(0, "QuickHeader", { fg = "#94a3b8" })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

      alpha.setup({
        layout = {
          { type = "padding", val = 6 },
          header,
          { type = "padding", val = 1 },
          quick,
          { type = "padding", val = 3 },
          dashboard.section.buttons,
        },
        opts = { margin = 5 },
      })
    end,
  },

  -- Catppuccin theme (matches tmux)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({ flavour = "latte" })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = { theme = "auto", icons_enabled = false },
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            width = 0.9,
            height = 0.9,
            preview_cutoff = 20,
          },
        },
      })
      vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
      vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
      vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>")
      vim.keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>")
    end,
  },

  -- Treesitter — nvim 0.12 has highlighting built-in, just need parsers
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_install = { "lua", "javascript", "typescript", "python", "json", "yaml", "markdown" },
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "File explorer" },
    },
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = true,
  },

  -- Comment toggle (gcc / gc in visual)
  { "numToStr/Comment.nvim", config = true },
}, { rocks = { enabled = false } })
