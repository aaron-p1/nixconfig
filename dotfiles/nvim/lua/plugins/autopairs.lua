local plugin = {}

function plugin.config()
	require('nvim-autopairs').setup{
		disable_filetype = {'TelescopePrompt', 'dap-repl', 'dapui_watches'}
	}
end

return plugin
