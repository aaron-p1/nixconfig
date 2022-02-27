local plugin = {}

function plugin.config()
	local dap = require('dap')
	local helper = require'helper'

	vim.keymap.set('n', '<F1>', dap.repl.toggle)
	vim.keymap.set('n', '<F2>', dap.step_over)
	vim.keymap.set('n', '<F3>', dap.step_into)
	vim.keymap.set('n', '<F4>', dap.step_out)
	-- continue or run
	vim.keymap.set('n', '<F5>', dap.continue)
	vim.keymap.set('n', '<F6>', dap.disconnect)
	vim.keymap.set('n', '<F7>', dap.run_to_cursor)
	vim.keymap.set('n', '<F8>', dap.toggle_breakpoint)
	vim.keymap.set('n', '<Leader><F8>', function ()
		dap.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))
	end)
	vim.keymap.set('n', '<F9>', dap.list_breakpoints)
	vim.keymap.set('n', '<F10>', dap.up)
	vim.keymap.set('n', '<Leader><F10>', dap.down)

	helper.registerPluginWk{
		prefix = '<leader>',
		map = {
			['<F8>'] = 'Conditional Breakpoint',
			['<F10>'] = 'Stack Down',
		}
	}

	-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

	dap.adapters.php = {
		type = 'executable',
		command = 'node',
		args = {
			os.getenv('HOME') .. '/.local/share/dap/vscode-php-debug/out/phpDebug.js' -- TODO install
		}
	}

	dap.configurations.php = {
		{
			type = 'php',
			request = 'launch',
			name = 'Listen for Xdebug',
			port = 9000,
			serverSourceRoot = '/var/www/html/',
			localSourceRoot = vim.fn.getcwd() .. '/',
		}
	}
end

return plugin
