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
			diagnostics.shellcheck,
			formatting.shellharden,
			-- nix
			formatting.nixfmt,
			diagnostics.statix,
			code_actions.statix,
		},
		on_attach = lsplugin.on_attach,
		capabilities = lsplugin.getCapabilities()
	})
end

return plugin
