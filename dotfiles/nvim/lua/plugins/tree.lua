local plugin = {}

function plugin.setup()
	vim.g.nvim_tree_disable_netrw = 0
	vim.g.nvim_tree_hijack_netrw = 0
end

function plugin.config()
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
