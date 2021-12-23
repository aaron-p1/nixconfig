local plugin = {}

function plugin.config()
	local nls = require("null-ls")
	local lsplugin = require('plugins.lspconfig')

	local diagnostics = nls.builtins.diagnostics
	local formatting = nls.builtins.formatting
	local code_actions = nls.builtins.code_actions

	nls.setup({
		sources = {
			-- shell
			diagnostics.shellcheck.with({command = "@shellcheck@/bin/shellcheck"}),
			formatting.shellharden.with({command = "@shellharden@/bin/shellharden"}),
			-- nix
			formatting.nixfmt.with({command = "@nixfmt@/bin/nixfmt"}),
			diagnostics.statix.with({command = "@statix@/bin/statix"}),
			code_actions.statix.with({command = "@statix@/bin/statix"}),
			-- elixir
			formatting.mix.with({command = "@elixir@/bin/mix"}),
			diagnostics.credo.with({command = "@elixir@/bin/mix"})
		},
		on_attach = lsplugin.on_attach,
		capabilities = lsplugin.getCapabilities()
	})
end

return plugin
