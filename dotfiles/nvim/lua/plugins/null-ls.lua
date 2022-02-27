local plugin = {}

function plugin.config()
  local nls = require("null-ls")
  local lsplugin = require("plugins.lspconfig")

  local diagnostics = nls.builtins.diagnostics
  local formatting = nls.builtins.formatting
  local code_actions = nls.builtins.code_actions

  nls.setup({
    sources = {
      -- shell
      diagnostics.shellcheck.with({ command = "@shellcheck@/bin/shellcheck" }),
      formatting.shellharden.with({ command = "@shellharden@/bin/shellharden" }),
      -- lua
      formatting.stylua.with({ command = "@stylua@/bin/stylua" }),
      -- nix
      diagnostics.statix.with({ command = "@statix@/bin/statix" }),
      formatting.nixfmt.with({ command = "@nixfmt@/bin/nixfmt" }),
      code_actions.statix.with({ command = "@statix@/bin/statix" }),
      -- elixir
      diagnostics.credo.with({ command = "@elixir@/bin/mix" }),
      formatting.surface.with({ command = "@elixir@/bin/mix", filetypes = { "surface" } }),
    },
    on_attach = lsplugin.on_attach,
    capabilities = lsplugin.getCapabilities(),
  })
end

return plugin
