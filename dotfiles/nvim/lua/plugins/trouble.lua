local plugin = {}

function plugin.config()
	local t = require('trouble')

	t.setup {
		mode = 'loclist'
	}

	vim.keymap.set('n', '<Leader>oo', function () t.toggle('document_diagnostics') end)
	vim.keymap.set('n', '<Leader>oi', function () t.toggle('lsp_implementations') end)
	vim.keymap.set('n', '<Leader>or', function () t.toggle('lsp_references') end)

	local helper = require'helper'

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			o = {
				name = 'Trouble',
				o = 'Document diagnostics',
				i = 'Implementations',
				r = 'References',
			}
		}
	}
end

return plugin
