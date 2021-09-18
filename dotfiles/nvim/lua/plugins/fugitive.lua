local plugin = {}

function plugin.config()
	local helper = require'helper'

	helper.keymap_cmd_leader_n_ns('gbb', 'Git blame')
end

return plugin
