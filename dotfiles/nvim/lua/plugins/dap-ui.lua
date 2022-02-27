local plugin = {}

function plugin.config()
	local ui = require'dapui'

	ui.setup{
		icons = {
			expanded = '▾',
			collapsed = '▸'
		},
		mappings = {
			-- Use a table to apply multiple mappings
			expand = {'<CR>'},
			open = 'o',
			remove = 'd',
			edit = 'e',
		},
		sidebar = {
			open_on_start = true,
			elements = {
				-- You can change the order of elements in the sidebar
				'scopes',
				'breakpoints',
				'stacks',
				'watches'
			},
			width = 60,
			position = 'left' -- Can be "left" or "right"
		},
		tray = {
			open_on_start = true,
			elements = {
				'repl'
			},
			height = 10,
			position = 'bottom' -- Can be "bottom" or "top"
		},
		floating = {
			max_height = nil, -- These can be integers or a float between 0 and 1.
			max_width = nil   -- Floats will be treated as percentage of your screen.
		}
	}

	vim.keymap.set('n', '<Leader>dd', ui.toggle)
	vim.keymap.set({'n', 'v'}, '<Leader>de', ui.eval)

	local helper = require'helper'

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			d = {
				name = 'dap',
				d = 'Toggle UI',
				e = 'Toggle eval',
			}
		}
	}
end

return plugin
