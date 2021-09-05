local plugin = {}

function plugin.config()
	require('telescope').load_extension('dap')
end

return plugin
