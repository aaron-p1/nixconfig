local helper = require('helper')
local fun = require('fun')

fun.iter({
	p = 'pull',
	f = 'fetch',
	P = 'push',
	l = 'log -25',
}):each(function (k, v)
	vim.keymap.set('n', '<Leader>g' .. k, '<Cmd>Git ' .. v .. '<CR>', {buffer = true})
end)

helper.registerPluginWk{
	prefix = '<leader>',
	buffer = 0,
	map = {
		g = {
			name = 'Git',
			p = 'Pull',
			f = 'Fetch',
			P = 'Push',
			l = 'Log 25',
		}
	}
}
