local plugin = {}

function plugin.config()
	local nls = require("null-ls")

	local diagnostics = nls.builtins.diagnostics
	local formatting = nls.builtins.formatting
	local code_actions = nls.builtins.code_actions

	nls.config({
		sources = {
			-- shell
			diagnostics.shellcheck,
			formatting.shfmt,
			formatting.shellharden,
		}
	})

	local lsplugin = require('plugins.lspconfig')

	require('lspconfig')['null-ls'].setup({
		on_attach = lsplugin.on_attach,
		capabilities = lsplugin.getCapabilities()
	})
end

return plugin
