local plugin = {}

function plugin.config()
	local wk = require('which-key')

	wk.setup {}

	wk.register(
		{
			t = {
				name = 'Tab'
			},
			r = {
				name = 'Compare Remote Files'
			},
		},
		{
			prefix = '<leader>'
		}
	)
end

return plugin
