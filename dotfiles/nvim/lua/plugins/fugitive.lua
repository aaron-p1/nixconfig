local plugin = {}

function plugin.config()
	local helper = require'helper'

	vim.keymap.set('n', '<Leader>gbb', '<Cmd>Git blame<CR>', {silent = true})

	helper.registerPluginWk{
		map = {
			g = {
				name = 'Git',
				b = {
					name = 'Blame',
					b = 'Whole file',
				}
			}
		}
	}

end

return plugin
