local plugin = {}

local servers = {
	-- dart
	'dartls',
	-- html
	{server = 'html', filetypes = {'html', 'blade'}},
	-- css
	'cssls',
	-- php
	--'phpactor',
	'intelephense',
	-- {'psalm', onlyDiagnostics},
	-- tex
	'texlab',
	-- json
	'jsonls',
	-- yaml
	'yamlls',
	-- graphql
	'graphql',
	-- vue
	'vuels',
}

function plugin.config()
	local on_attach = function (client, bufnr)
		local helper = require'helper'

		-- helper functions
		local function keymap_b_cmd_n_ns(...)
			helper.keymap_b_cmd_n_ns(bufnr, ...)
		end
		local function keymap_b_cmd_leader_n_ns(...)
			helper.keymap_b_cmd_leader_n_ns(bufnr, ...)
		end
		local function keymap_b_lua_n_ns(...)
			helper.keymap_b_lua_n_ns(bufnr, ...)
		end
		local function keymap_b_lua_leader_n_ns(...)
			helper.keymap_b_lua_leader_n_ns(bufnr, ...)
		end

		local function buf_set_keymap(...)
			vim.api.nvim_buf_set_keymap(bufnr, ...)
		end
		local function buf_set_option(...)
			vim.api.nvim_buf_set_option(bufnr, ...)
		end

		buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

		keymap_b_lua_n_ns('gD', 'vim.lsp.buf.declaration()')
		keymap_b_lua_n_ns('gd', 'vim.lsp.buf.definition()')
		keymap_b_lua_n_ns('gi', 'vim.lsp.buf.implementation()')
		keymap_b_lua_n_ns('K', 'vim.lsp.buf.hover()')
		keymap_b_lua_leader_n_ns('lwa', 'vim.lsp.buf.add_workspace_folder()')
		keymap_b_lua_leader_n_ns('lwr', 'vim.lsp.buf.remove_workspace_folder()')
		keymap_b_lua_leader_n_ns(
			'lwl', 'print(vim.inspect(vim.lsp.buf.list_workspace_folders()))')
		keymap_b_lua_leader_n_ns('lD', 'vim.lsp.buf.type_definition()')
		keymap_b_lua_n_ns('gr', 'vim.lsp.buf.references()')
		keymap_b_lua_leader_n_ns(
			'le', 'vim.lsp.diagnostic.show_line_diagnostics()')
		keymap_b_lua_n_ns('[d', 'vim.lsp.diagnostic.goto_prev()')
		keymap_b_lua_n_ns(']d', 'vim.lsp.diagnostic.goto_next()')
		keymap_b_lua_leader_n_ns('lq', 'vim.lsp.diagnostic.set_loclist()')
		keymap_b_lua_leader_n_ns('lf', 'vim.lsp.buf.formatting()')

		-- lsp saga
		keymap_b_cmd_leader_n_ns('lc', 'Lspsaga code_action')
		keymap_b_cmd_n_ns('<C-k>', 'Lspsaga signature_help')
		keymap_b_cmd_leader_n_ns('lr', 'Lspsaga rename')
		keymap_b_cmd_leader_n_ns('lp', 'Lspsaga preview_definition')
		-- scroll hover doc or definition preview
		keymap_b_lua_n_ns(
			'<A-d>', [[require('lspsaga.action').smart_scroll_with_saga(1)]])
		keymap_b_lua_n_ns(
			'<A-u>', [[require('lspsaga.action').smart_scroll_with_saga(-1)]])

		-- which key
		helper.registerPluginWk{
			prefix = '<leader>',
			buffer = bufnr,
			map = {
				l = {
					name = 'LSP',
					w = {
						name = 'Workspace',
					}
				},
			},
		}

		-- lsp signature
		require'lsp_signature'.on_attach{
			bind = true,
			hint_prefix = '→ ',
			use_lspsaga = true
		}
	end

	local nvim_lsp = require('lspconfig')
	-- local configs = require('lspconfig/configs')
	-- local util = require('lspconfig/util')

	-- psalm
	local serverExec = vim.fn.glob('vendor/bin/psalm')
	if (serverExec == '') then
		serverExec = 'psalm'
	end

	-- configs['psalm'] = {
	-- 	default_config = {
	-- 		cmd = {serverExec, '--language-server'},
	-- 		filetypes = {'php'},
	-- 		root_dir = util.root_pattern('composer.json', '.git')
	-- 	}
	-- }

	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

	local onlyDiagnostics = vim.lsp.protocol.make_client_capabilities()
	onlyDiagnostics.textDocument = {
		publishDiagnostics = {
			relatedInformation = true,
			tagSupport = {
				valueSet = { 1, 2 }
			}
		}
	}

	for _, lspdef in ipairs(servers) do
		local lsp = lspdef
		local cap = capabilities

		if (type(lspdef) == 'table') then
			local server = lspdef.server

			lspdef.server = nil

			if (not lspdef.on_attach) then
				lspdef.on_attach = on_attach
			end
			if (not lspdef.capabilities) then
				lspdef.capabilities = capabilities
			end

			nvim_lsp[server].setup(lspdef)
		else
			nvim_lsp[lsp].setup {
				on_attach = on_attach,
				capabilities = cap,
			}
		end
	end

	-- lua
	local runtime_path = vim.split(package.path, ';')
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")

	nvim_lsp.sumneko_lua.setup {
		on_attach = on_attach,
		capabilities = capabilities,
		cmd = {'lua-language-server'},
		settings = {
			Lua = {
				runtime = {
					-- Tell the language server which version of Lua you're using
					-- (most likely LuaJIT in the case of Neovim)
					version = 'LuaJIT',
					-- Setup your lua path
					path = runtime_path,
				},
				diagnostics = {
					-- Get the language server to recognize the `vim` global
					globals = {'vim'},
				},
				workspace = {
					-- Make the server aware of Neovim runtime files
					library = vim.api.nvim_get_runtime_file("", true),
				},
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
			},
		},
	}
end

return plugin
