local plugin = {}

function plugin.config()
	require('nvim-tree').setup{
		disable_netrw = false,
		hijack_netrw = false,
	}

	local helper = require'helper'

	helper.keymap_cmd_leader_n_ns('bb', 'NvimTreeToggle')
	helper.keymap_cmd_leader_n_ns('br', 'NvimTreeRefresh')
	helper.keymap_cmd_leader_n_ns('bf', 'NvimTreeFindFile')

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			b = {
				name = 'Nvim Tree'
			}
		}
	}
end

return plugin
