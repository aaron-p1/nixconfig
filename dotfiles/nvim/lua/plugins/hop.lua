local plugin = {}

function plugin.config()
	require'hop'.setup()

	local helper = require'helper'

	helper.keymap_cmd_leader_n_ns('hw', 'HopWord')
	helper.keymap_cmd_leader_n_ns('h1', 'HopChar1')
	helper.keymap_cmd_leader_n_ns('h2', 'HopChar2')

	helper.keymap_cmd_leader_v_ns('hw', 'HopWord')
	helper.keymap_cmd_leader_v_ns('h1', 'HopChar1')
	helper.keymap_cmd_leader_v_ns('h2', 'HopChar2')

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			h = {
				name = 'Hop',
			},
		}
	}
end

return plugin
