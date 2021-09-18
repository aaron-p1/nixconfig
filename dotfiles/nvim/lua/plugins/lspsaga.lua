local plugin = {}

function plugin.config()
	require'lspsaga'.init_lsp_saga{
		code_action_keys = {
			quit = {'q', '<Esc>', '<C-c>'},
			exec = '<CR>'
		},
		rename_action_keys = {
			quit = {'<Esc>', '<C-c>'},
			exec = '<CR>'
		},
		code_action_prompt = {
			enable = false
		},
	}
end

return plugin
