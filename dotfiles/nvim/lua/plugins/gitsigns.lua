local plugin = {}

function plugin.config()
	require('gitsigns').setup{
		keymaps = {
			-- Default keymap options
			noremap = true,

			['n ]c'] = {
				expr = true,
				"&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'",
			},
			['n [c'] = {
				expr = true,
				"&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'",
			},

			['n <leader>ghs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
			['v <leader>ghs'] = '<cmd>lua '
				..'require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
			['n <leader>ghu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
			['n <leader>ghr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
			['v <leader>ghr'] = '<cmd>lua '
				..'require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
			['n <leader>gR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
			['n <leader>ghp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
			['n <leader>gb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

			-- Text objects
			['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
			['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>'
		},
		update_debounce = 300
	}

	local helper = require'helper'

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			g = {
				name = 'Git',
				h = {
					name = 'Hunk'
				}
			}
		}
	}
end

return plugin
