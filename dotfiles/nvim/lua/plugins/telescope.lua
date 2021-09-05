local plugin = {}

function plugin.config()
	local t = require('telescope')
	t.setup {
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = 'smart_case',
			}
		}
	}

	t.load_extension('fzf')

	local helper = require'helper'
	-- file
	helper.keymap_cmd_leader_n_ns('fa', 'Telescope find_files find_command="fd,-uu,--type=f"')
	helper.keymap_cmd_leader_n_ns('ff', 'Telescope find_files find_command=fd')
	helper.keymap_cmd_leader_n_ns('fr', 'Telescope live_grep')
	helper.keymap_cmd_leader_n_ns('fu', 'Telescope file_browser')
	-- vim
	helper.keymap_cmd_leader_n_ns('fb', 'Telescope buffers')
	helper.keymap_cmd_leader_n_ns('fm', 'Telescope marks')
	helper.keymap_cmd_leader_n_ns('fcr', 'Telescope current_buffer_fuzzy_find')
	-- lsp
	helper.keymap_cmd_leader_n_ns('flr', 'Telescope lsp_refrences')
	helper.keymap_cmd_leader_n_ns('fls', 'Telescope lsp_document_symbols')
	-- (maybe code actions)
	-- helper.keymap_cmd_leader_n_ns('flc', 'Telescope lsp_code_actions')
	helper.keymap_cmd_leader_n_ns('fli', 'Telescope lsp_implementations')
	helper.keymap_cmd_leader_n_ns('fld', 'Telescope lsp_definitions')
	-- git
	helper.keymap_cmd_leader_n_ns('fgc', 'Telescope git_commits')
	helper.keymap_cmd_leader_n_ns('fgb', 'Telescope git_bcommits')
	helper.keymap_cmd_leader_n_ns('fgt', 'Telescope git_stash')
	-- treesitter
	helper.keymap_cmd_leader_n_ns('ft', 'Telescope treesitter')


	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			f = {
				name = 'Telescope',
				g = {
					name = 'Git',
				},
				c = {
					name = 'Current Buffer',
				},
				l = {
					name = 'LSP',
				},
			},
		}
	}
end

return plugin
