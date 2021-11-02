local plugin = {}

function plugin.config()
	require('nvim-autopairs').setup{
		disable_filetype = {'TelescopePrompt', 'dap-repl', 'dapui_watches'}
	}

	local cmp_autopairs = require('nvim-autopairs.completion.cmp')
	local cmp = require('cmp')
	cmp.event:on(
		'confirm_done',
		cmp_autopairs.on_confirm_done({
				map_cr = true, --  map <CR> on insert mode
				map_complete = true, -- it will auto insert `(` after select function or method item
				auto_select = true -- automatically select the first item
		}))
end

return plugin
