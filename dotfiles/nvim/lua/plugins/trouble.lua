local plugin = {}

function plugin.config()
	require('trouble').setup {
		mode = 'loclist'
	}

	local helper = require'helper'

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			o = {
				name = 'Trouble'
			}
		}
	}

	helper.keymap_cmd_leader_n_ns('oo', 'TroubleToggle document_diagnostics')
	helper.keymap_cmd_leader_n_ns('oi', 'TroubleToggle lsp_implementations')
	helper.keymap_cmd_leader_n_ns('or', 'TroubleToggle lsp_references')
end

return plugin
