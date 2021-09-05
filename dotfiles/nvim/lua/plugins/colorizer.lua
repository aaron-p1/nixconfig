local plugin = {}

function plugin.config()
	require'colorizer'.setup({'*'}, {
		rgb_fn = true,
		hsl_fn = true
	})
end

return plugin
