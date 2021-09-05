local plugin = {}

function plugin.config()
	local helper = require'helper'

	helper.keymap_lua_n_ns('<F1>', [[require'dap'.repl.toggle()]])
	helper.keymap_lua_n_ns('<F2>', [[require'dap'.step_over()]])
	helper.keymap_lua_n_ns('<F3>', [[require'dap'.step_into()]])
	helper.keymap_lua_n_ns('<F4>', [[require'dap'.step_out()]])
	-- continue or run
	helper.keymap_lua_n_ns('<F5>', [[require'dap'.continue()]])
	helper.keymap_lua_n_ns('<F6>', [[require'dap'.disconnect()]])
	helper.keymap_lua_n_ns('<F7>', [[require'dap'.run_to_cursor()]])
	helper.keymap_lua_n_ns('<F8>', [[require'dap'.toggle_breakpoint()]])
	helper.keymap_lua_leader_n_ns(
		'<F8>',
		[[require'dap'.toggle_breakpoint(vim.fn.input('Breakpoint condition: '))]]
	)
	helper.keymap_lua_n_ns('<F9>', [[require'dap'.list_breakpoints()]])
	helper.keymap_lua_n_ns('<F10>', [[require'dap'.up()]])
	helper.keymap_lua_leader_n_ns('<F10>', [[require'dap'.down()]])


	local dap = require('dap')

	-- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation

	dap.adapters.php = {
		type = 'executable',
		command = 'node',
		args = {
			os.getenv('HOME') .. '/.local/share/dap/vscode-php-debug/out/phpDebug.js'
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
