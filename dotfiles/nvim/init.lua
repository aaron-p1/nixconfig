-- Install packer
local install_path = vim.fn.stdpath 'data' ..
	'/site/pack/packer/start/packer.nvim'

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim '
	  .. install_path)
end

vim.cmd[[
  augroup Packer
    autocmd!
    autocmd BufWritePost ~/.config/nvim/init.lua nested source <afile> | PackerCompile
  augroup end
]]

local helper = require'helper'

local use = require('packer').use
local use_rocks = require('packer').use_rocks
require('packer').startup({
	function()
		use 'wbthomason/packer.nvim'

		-- color scheme
		use {
			'morhetz/gruvbox',
			config = [[require'plugins.gruvbox'.config()]]
		}

		-- small text utilities
		use 'tpope/vim-commentary'
		use 'tpope/vim-surround'
		use 'tpope/vim-unimpaired'
		use 'tpope/vim-repeat'
		use 'tpope/vim-abolish'
		use 'tpope/vim-characterize'
		use {
			'AndrewRadev/splitjoin.vim',
			keys = {'gS', 'gJ'}
		}
		use {
			'norcalli/nvim-colorizer.lua',
			config = [[require'plugins.colorizer'.config()]]
		}
		use {
			'lukas-reineke/indent-blankline.nvim',
			config = [[require'plugins.indent-blankline'.config()]]
		}
		use {
			'windwp/nvim-autopairs',
			after = {'nvim-cmp'},
			config = [[require'plugins.autopairs'.config()]]
		}
		use {
			'windwp/nvim-ts-autotag',
		}

		-- config
		use {
			'editorconfig/editorconfig-vim',
			config = [[require'plugins.editorconfig'.config()]]
		}

		-- status line
		use {
			'itchyny/lightline.vim',
			config = [[require'plugins.lightline'.config()]]
		}

		use {
			'nvim-treesitter/nvim-treesitter',
			run = ':TSUpdate',
			wants = {'nvim-ts-autotag'},
			config = [[require'plugins.treesitter'.config()]]
		}
		use {
			'nvim-treesitter/nvim-treesitter-textobjects',
			requires = 'nvim-treesitter/nvim-treesitter',
			after = {'which-key.nvim', 'nvim-treesitter'},
			config = [[require'plugins.treesitter-textobjects'.config()]]
		}

		-- syntax
		use 'sheerun/vim-polyglot'

		-- helper
		use {
			'folke/which-key.nvim',
			config = [[require'plugins.which-key'.config()]]
		}
		use {
			'phaazon/hop.nvim',
			after = {'which-key.nvim'},
			keys = {'<leader>h1', '<leader>h2', '<leader>hw'},
			config = [[require'plugins.hop'.config()]]
		}

		-- git
		use {
			'tpope/vim-fugitive',
			cmd = {'Git', 'Gpull', 'Gfetch', 'Gstatus', 'Glog', 'Gdiffsplit',
				'Gwrite', 'Gread', 'GRename', 'GMove'},
			config = [[require'plugins.fugitive'.config()]]
		}
		use {
			'lewis6991/gitsigns.nvim',
			requires = {'nvim-lua/plenary.nvim'},
			after = {'vim-fugitive'},
			config = [[require'plugins.gitsigns'.config()]]
		}

		-- file manager
		use {
			'kyazdani42/nvim-tree.lua',
			requires = {'kyazdani42/nvim-web-devicons'},
			after = {'which-key.nvim'},
			config = [[require'plugins.tree'.config()]]
		}

		-- fuzzy finder
		use {
			'nvim-telescope/telescope.nvim',
			requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
			after = {'trouble.nvim'},
			wants = {'telescope-fzf-native.nvim', 'telescope-symbols.nvim'},
			config = [[require'plugins.telescope'.config()]]
		}
		use {
			'nvim-telescope/telescope-fzf-native.nvim',
			requires = {'nvim-telescope/telescope.nvim'},
			run = 'make',
			config = [[require'plugins.telescope-fzf-native'.config()]]
		}
		use {
			'nvim-telescope/telescope-symbols.nvim',
		}
		use {
			'nvim-telescope/telescope-dap.nvim',
			requires = {'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap'},
			after = {'telescope.nvim', 'nvim-dap'},
			-- TODO keymaps for common commands
			config = [[require'plugins.telescope-dap'.config()]]
		}

		-- snippets
		use {
			'L3MON4D3/LuaSnip',
			wants = 'friendly-snippets',
			opt = true,
			config = [[require'plugins.luasnip'.config()]]
		}
		use {
			'rafamadriz/friendly-snippets',
			opt = true,
		}

		-- lsp
		use {
			'neovim/nvim-lspconfig',
			config = [[require'plugins.lspconfig'.config()]],
			wants = {'telescope.nvim', 'which-key.nvim', 'lsp_signature.nvim', 'nvim-cmp'},
			ft = {'dart', 'php', 'blade', 'html', 'css', 'scss', 'less', 'tex', 'bib', 'lua', 'json', 'yaml', 'graphql', 'vue', 'haskell', 'nix'},
		}
		use {
			'jose-elias-alvarez/null-ls.nvim',
			requires = {'nvim-lua/plenary.nvim'},
			config = [[require'plugins.null-ls'.config()]],
			after = {'nvim-lspconfig'}
		}
		use {
			'hrsh7th/nvim-cmp',
			event = 'InsertCharPre',
			wants = {'LuaSnip'},
			config = [[require'plugins.cmp'.config()]]
		}
		use {
			'hrsh7th/cmp-buffer',
			after = {'nvim-cmp'},
		}
		use {
			'hrsh7th/cmp-path',
			after = {'nvim-cmp'},
		}
		use {
			'hrsh7th/cmp-calc',
			after = {'nvim-cmp'},
		}
		use {
			'saadparwaiz1/cmp_luasnip',
			wants = {'LuaSnip'},
			after = {'nvim-cmp'},
		}
		use {
			'hrsh7th/cmp-nvim-lsp',
			after = {'nvim-cmp'},
		}
		use {
			'tzachar/cmp-tabnine',
			run='./install.sh',
			after = {'nvim-cmp'},
			config = [[require'plugins.cmp-tabnine'.config()]]
		}
		use {
			'ray-x/lsp_signature.nvim',
			opt = true,
		}

		-- diagnostics
		use {
			'folke/trouble.nvim',
			requires = 'kyazdani42/nvim-web-devicons',
			after = {'which-key.nvim'},
			config = [[require'plugins.trouble'.config()]]
		}

		-- dap
		use {
			'mfussenegger/nvim-dap',
			keys = {'<F5>', '<F8>'},
			config = [[require'plugins.dap'.config()]]
		}
		use {
			'theHamsta/nvim-dap-virtual-text',
			requires = {'mfussenegger/nvim-dap'},
			after = {'nvim-dap'},
			config = [[require'plugins.dap-virtual-text'.config()]]
		}
		use {
			'rcarriga/nvim-dap-ui',
			requires = {'mfussenegger/nvim-dap'},
			after = {'nvim-dap'},
			config = [[require'plugins.dap-ui'.config()]]
		}

		use_rocks 'fun'
	end,
	config = {
		display = {
			open_fn = require('packer.util').float,
		}
	}
})

helper.setOptions(vim.o, {
	-- hidden changed buffers
	'hidden',
	-- show chars bottom left
	'showcmd',
	-- highlight search
	'hlsearch',
	-- hsow position in file
	'ruler',
	-- confirm closing unsaved files
	'confirm',
	-- line numbers
	'number', 'relativenumber',
	-- don't break line inside word
	'linebreak',
	-- jump while searching
	'incsearch',
	-- search case
	'ignorecase', 'smartcase',
	-- gui colors
	'termguicolors',
	-- split buffers bottom right
	'splitbelow', 'splitright',
	-- save undo history
	'undofile',
	--
	'cursorline',

	background = 'dark',

	timeoutlen = 500,

	completeopt = 'menuone,noselect',

	omnifunc = 'syntaxcomplete#Complete',

	showbreak = '―→',
	-- indent
	tabstop = 4,
	shiftwidth = 4,

	-- folding
	foldmethod = 'indent',
	foldlevelstart = 99,
	-- scrolling
	scrolljump = -10,
	-- spelling
	spelllang = 'de',
	spellfile = '~/.config/nvim/spell/de.utf-8.add',
	-- dict completion
	dictionary = '/usr/share/dict/ngerman,/usr/share/dict/usa',
})

-- TERMINAL
-- alt + Esc for leaving terminal
vim.api.nvim_set_keymap('t', '<A-Esc>', [[<c-\><c-n>]], { noremap = true })

--Disable numbers in terminal mode
vim.cmd[[
	augroup Terminal
		autocmd!
		autocmd TermOpen * set nonumber norelativenumber
	augroup end
]]

-- YANK
-- Highlight on yank
vim.cmd[[
	augroup YankHighlight
		autocmd!
		autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=300}
	augroup end
]]

-- Y yank until the end of line
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })

-- noh
helper.keymap_cmd_leader_n_ns('n', 'noh')

-- tab
helper.keymap_cmd_leader_n_ns('tt', 'tablast')
helper.keymap_lua_leader_n_ns('tc', [[ vim.api.nvim_command('tabclose'); for i=2,vim.v.count,1 do vim.api.nvim_command('tabclose') end]])
helper.keymap_cmd_leader_n_ns('to', 'tabonly')

-- syntax
helper.keymap_cmd_leader_n_ns('xs', 'syntax sync fromstart')

-- Compare Remote
local compare_remotes = {
	exo = 'scp://exoshare//var/www/html/exomind/',
}

function CompareRemotes(remote)
	local local_path = vim.api.nvim_eval(
		[[system('realpath --relative-base=' . getcwd() . ' ' . expand('%:p'))]])

	if (string.sub(local_path, 1, 1) == '/') then
		vim.cmd([[echoerr 'Not a Project File: ']] .. local_path)
		return
	end

	local remote_path = compare_remotes[remote] .. local_path
	vim.cmd('tab split')
	vim.cmd('vertical diffsplit ' .. remote_path)
end

helper.keymap_lua_leader_n_ns('rexo', [[CompareRemotes('exo')]])

vim.cmd[[
	augroup my_scp
		autocmd!
		autocmd BufNewFile,BufRead,BufLeave scp://* setlocal bufhidden=delete
	augroup END
]]
