-- Install packer
local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

local helper = require("helper")
local packer = require("packer")

local use = packer.use
local use_rocks = packer.use_rocks
packer.startup({
  function()
    use("wbthomason/packer.nvim")

    -- color scheme
    use({
      "morhetz/gruvbox",
      config = [[require('plugins.gruvbox').config()]],
    })

    -- small text utilities
    use({
      "numToStr/Comment.nvim",
      config = [[require('plugins.comment').config()]],
    })
    use("tpope/vim-surround")
    use("tpope/vim-unimpaired")
    use("tpope/vim-repeat")
    use("tpope/vim-abolish")
    use("tpope/vim-characterize")
    use({
      "AndrewRadev/splitjoin.vim",
      keys = { "gS", "gJ" },
    })
    use({
      "norcalli/nvim-colorizer.lua",
      config = [[require('plugins.colorizer').config()]],
    })
    use({
      "lukas-reineke/indent-blankline.nvim",
      config = [[require('plugins.indent-blankline').config()]],
    })
    use({
      "windwp/nvim-autopairs",
      after = { "nvim-cmp" },
      config = [[require('plugins.autopairs').config()]],
    })
    use({
      "windwp/nvim-ts-autotag",
    })

    -- config
    use({
      "editorconfig/editorconfig-vim",
      config = [[require('plugins.editorconfig').config()]],
    })

    -- status line
    use({
      "itchyny/lightline.vim",
      config = [[require('plugins.lightline').config()]],
    })

    use({
      "nvim-treesitter/nvim-treesitter",
      run = ":TSUpdate",
      wants = { "nvim-ts-autotag" },
      config = [[require('plugins.treesitter').config()]],
    })
    use({
      "nvim-treesitter/nvim-treesitter-textobjects",
      requires = "nvim-treesitter/nvim-treesitter",
      after = { "which-key.nvim", "nvim-treesitter" },
      config = [[require('plugins.treesitter-textobjects').config()]],
    })
    use({
      "nvim-treesitter/playground",
      requires = "nvim-treesitter/nvim-treesitter",
      after = { "nvim-treesitter" },
      config = [[require('plugins.treesitter-playground').config()]],
    })

    -- syntax
    use("sheerun/vim-polyglot")
    use("dylon/vim-antlr")

    -- helper
    use({
      "folke/which-key.nvim",
      config = [[require('plugins.which-key').config()]],
    })

    -- git
    use({
      "tpope/vim-fugitive",
      cmd = { "Git", "Gpull", "Gfetch", "Gstatus", "Glog", "Gdiffsplit", "Gwrite", "Gread", "GRename", "GMove" },
      config = [[require('plugins.fugitive').config()]],
    })
    use({
      "lewis6991/gitsigns.nvim",
      requires = { "nvim-lua/plenary.nvim" },
      after = { "vim-fugitive" },
      config = [[require('plugins.gitsigns').config()]],
    })

    -- file manager
    use({
      "kyazdani42/nvim-tree.lua",
      requires = { "kyazdani42/nvim-web-devicons" },
      after = { "which-key.nvim" },
      config = [[require('plugins.tree').config()]],
    })

    -- fuzzy finder
    use({
      "nvim-telescope/telescope.nvim",
      requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
      wants = { "trouble.nvim", "telescope-fzf-native.nvim", "telescope-symbols.nvim", "telescope-ui-select.nvim" },
      config = [[require('plugins.telescope').config()]],
    })
    use({
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
    })
    use("nvim-telescope/telescope-ui-select.nvim")
    use("nvim-telescope/telescope-symbols.nvim")
    use({
      "nvim-telescope/telescope-dap.nvim",
      requires = { "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap" },
      after = { "telescope.nvim", "nvim-dap" },
      -- TODO keymaps for common commands
      config = [[require('plugins.telescope-dap').config()]],
    })

    -- snippets
    use({
      "L3MON4D3/LuaSnip",
      config = [[require('plugins.luasnip').config()]],
    })

    -- lsp
    use({
      "neovim/nvim-lspconfig",
      config = [[require('plugins.lspconfig').config()]],
      wants = { "telescope.nvim", "which-key.nvim", "lsp_signature.nvim", "nvim-cmp" },
    })
    use("mfussenegger/nvim-jdtls") -- java
    use({
      "jose-elias-alvarez/null-ls.nvim",
      requires = { "nvim-lua/plenary.nvim" },
      config = [[require('plugins.null-ls').config()]],
      after = { "nvim-lspconfig" },
    })
    use({
      "hrsh7th/nvim-cmp",
      config = [[require('plugins.cmp').config()]],
    })
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-calc")
    use("hrsh7th/cmp-cmdline")
    use("saadparwaiz1/cmp_luasnip")
    use("hrsh7th/cmp-omni")
    use("hrsh7th/cmp-nvim-lsp")
    use({
      "tzachar/cmp-tabnine",
      run = "./install.sh",
      after = { "nvim-cmp" },
      config = [[require('plugins.cmp-tabnine').config()]],
    })
    use("ray-x/lsp_signature.nvim")

    -- diagnostics
    use({
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      wants = { "which-key.nvim" },
      config = [[require('plugins.trouble').config()]],
    })

    -- dap
    use({
      "mfussenegger/nvim-dap",
      keys = { "<F5>", "<F8>" },
      config = [[require('plugins.dap').config()]],
    })
    use({
      "theHamsta/nvim-dap-virtual-text",
      requires = { "mfussenegger/nvim-dap" },
      after = { "nvim-dap" },
      config = [[require('plugins.dap-virtual-text').config()]],
    })
    use({
      "rcarriga/nvim-dap-ui",
      requires = { "mfussenegger/nvim-dap" },
      after = { "nvim-dap" },
      config = [[require('plugins.dap-ui').config()]],
    })

    use("vim-test/vim-test")

    -- tex
    use({
      "lervag/vimtex",
      config = [[require('plugins.vimtex').config()]],
    })

    use_rocks("fun")
  end,
  config = {
    display = {
      open_fn = require("packer.util").float,
    },
  },
})

helper.setOptions(vim.o, {
  -- hidden changed buffers
  "hidden",
  -- show chars bottom left
  "showcmd",
  -- highlight search
  "hlsearch",
  -- hsow position in file
  "ruler",
  -- confirm closing unsaved files
  "confirm",
  -- line numbers
  "number",
  "relativenumber",
  -- don't break line inside word
  "linebreak",
  -- jump while searching
  "incsearch",
  -- search case
  "ignorecase",
  "smartcase",
  -- gui colors
  "termguicolors",
  -- split buffers bottom right
  "splitbelow",
  "splitright",
  -- save undo history
  "undofile",
  --
  "cursorline",
  -- ! don't use tmp file
  "noshelltemp",

  background = "dark",

  timeoutlen = 500,

  completeopt = "menuone,noselect",

  omnifunc = "syntaxcomplete#Complete",

  showbreak = "─→",
  -- indent
  tabstop = 4,
  shiftwidth = 4,

  -- folding
  foldmethod = "indent",
  foldlevelstart = 99,
  -- scrolling
  scrolljump = -10,
  -- spelling
  spelllang = "de",
  spellfile = "~/.config/nvim/spell/de.utf-8.add",
  -- dict completion
  dictionary = "/usr/share/dict/ngerman,/usr/share/dict/usa",
})

vim.cmd("language en_US.utf8")

-- TERMINAL
-- alt + Esc for leaving terminal
vim.keymap.set("t", "<A-Esc>", "<C-\\><C-N>")

--Disable numbers in terminal mode
local group_terminal = vim.api.nvim_create_augroup("Terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = group_terminal,
  callback = function()
    helper.setOptions(vim.bo, { "nonumber", "norelativenumber" })
  end,
})

-- YANK
-- Highlight on yank
local group_yank_highlight = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group_yank_highlight,
  callback = function()
    vim.highlight.on_yank({ timeout = 300 })
  end,
})

vim.keymap.set("n", "<Leader>du", "<Cmd>diffupdate<CR>", { silent = true })

-- noh
vim.keymap.set("n", "<Leader>n", "<Cmd>nohlsearch<CR>", { silent = true })

-- tab
vim.keymap.set("n", "<Leader>tc", function()
  local count = vim.v.count == 0 and 1 or vim.v.count
  pcall(function()
    for _ = 1, count do
      vim.api.nvim_command("tabclose")
    end
  end)
end)
vim.keymap.set("n", "<Leader>to", "<Cmd>tabonly<CR>", { silent = true })

-- Compare Remote
local compare_remotes = {
  exo = "scp://exo//var/www/html/exomind/",
}

local function compareRemotes(remote)
  local local_path = vim.api.nvim_eval([[system('realpath --relative-base=' . getcwd() . ' ' . expand('%:p'))]])

  if string.sub(local_path, 1, 1) == "/" then
    vim.cmd([[echoerr 'Not a Project File: ']] .. local_path)
    return
  end

  local remote_path = compare_remotes[remote] .. local_path
  vim.cmd("tab split")
  vim.cmd("vertical diffsplit " .. remote_path)
end

vim.keymap.set("n", "<Leader>rexo", function()
  compareRemotes("exo")
end)

local group_my_scp = vim.api.nvim_create_augroup("MyScp", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile,BufRead,BufLeave", {
  group = group_my_scp,
  pattern = "scp://*",
  callback = function()
    vim.bo.bufhidden = "delete"
  end,
})
