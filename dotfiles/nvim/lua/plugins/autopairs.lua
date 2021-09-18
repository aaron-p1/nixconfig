local plugin = {}

function plugin.config()
	require('nvim-autopairs').setup{
		disable_filetype = {'TelescopePrompt', 'dap-repl', 'dapui_watches'}
	}
	require("nvim-autopairs.completion.cmp").setup({
		map_cr = true, --  map <CR> on insert mode
		map_complete = true, -- it will auto insert `(` after select function or method item
		auto_select = true -- automatically select the first item
	})
end

return plugin
