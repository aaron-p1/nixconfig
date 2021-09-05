local plugin = {}

function plugin.config()
	require'compe'.setup {
		enabled = true,
		autocomplete = true,
		source = {
			path = true,
			calc = true,
			nvim_lsp = true,
			luasnip = true
		}
	}
end

return plugin
