local plugin = {}

function plugin.config()
	require('trouble').setup {
		mode = 'loclist'
	}

	local helper = require'helper'

	helper.keymap_cmd_leader_n_ns('ol', 'Trouble loclist')
	helper.keymap_cmd_leader_n_ns('od', 'Trouble lsp_document_diagnostics')

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			o = {
				name = 'Trouble'
			}
		}
	}
end

return plugin
