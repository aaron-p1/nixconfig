local plugin = {}

function plugin.config()
	local t = require('telescope')

	local trouble = require('trouble.providers.telescope')

	t.setup {
		defaults = {
			mappings = {
				i = {
					['<leader>ot'] = trouble.open_with_trouble
				},
				n = {
					['<leader>ot'] = trouble.open_with_trouble
				}
			},
			vimgrep_arguments = {
				"@rg@/bin/rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case"
			},
			preview = {
				filesize_limit = 1; -- 1 MB
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = 'smart_case',
			},
			['ui-select'] = {
				require('telescope.themes').get_dropdown {
					-- even more opts
				}
			}
		}
	}

	t.load_extension('fzf')
	t.load_extension('ui-select')

	local tb = require('telescope.builtin')
	local helper = require'helper'
	-- file
	vim.keymap.set('n', '<Leader>fa', function ()
		tb.find_files({find_command = {'@fd@/bin/fd', '--type=file', '--size=-1M', '--hidden', '--strip-cwd-prefix', '--no-ignore'}})
	end)
	vim.keymap.set('n', '<Leader>ff', function ()
		tb.find_files({find_command = {'@fd@/bin/fd', '--type=file', '--size=-1M', '--hidden', '--strip-cwd-prefix', '--exclude=.git'}})
	end)
	vim.keymap.set('n', '<Leader>fr', tb.live_grep)
	-- vim
	vim.keymap.set('n', '<Leader>fb', tb.buffers)
	vim.keymap.set('n', '<Leader>fm', tb.marks)
	vim.keymap.set('n', '<Leader>fcr', tb.current_buffer_fuzzy_find)
	-- lsp
	vim.keymap.set('n', '<Leader>flr', tb.lsp_references)
	vim.keymap.set('n', '<Leader>fls', tb.lsp_document_symbols)
	vim.keymap.set('n', '<Leader>fli', tb.lsp_implementations)
	vim.keymap.set('n', '<Leader>fld', tb.lsp_definitions)
	-- git
	vim.keymap.set('n', '<Leader>fgc', tb.git_commits)
	vim.keymap.set('n', '<Leader>fgb', tb.git_bcommits)
	vim.keymap.set('n', '<Leader>fgf', tb.git_stash)
	-- treesitter
	vim.keymap.set('n', '<Leader>ft', tb.treesitter)

	--symbols
	vim.keymap.set('n', '<Leader>fs', tb.symbols)


	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			f = {
				name = 'Telescope',
				a = 'All Files',
				f = 'Files',
				r = 'Live grep',
				b = 'Buffers',
				m = 'Marks',
				t = 'Treesitter nodes',
				s = 'Symbols',
				c = {
					name = 'Current Buffer',
					r = 'Fuzzy find',
				},
				l = {
					name = 'LSP',
					r = 'References',
					s = 'Document symbols',
					i = 'Implementations',
					d = 'Definitions',
				},
				g = {
					name = 'Git',
					c = 'Commits',
					b = 'BCommits',
					t = 'Stash'
				},
			},
		}
	}
end

return plugin
