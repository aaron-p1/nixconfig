local plugin = {}

local servers = {
  -- dart
  { server = "dartls" },
  -- html
  {
    server = "html",
    filetypes = { "html", "blade" },
    cmd = { "@vscodelsp@/bin/vscode-html-language-server", "--stdio" },
  },
  -- css
  { server = "cssls", cmd = { "@vscodelsp@/bin/vscode-css-language-server", "--stdio" } },
  -- php
  { server = "intelephense", cmd = { "@intelephense@/bin/intelephense", "--stdio" } },
  -- json
  { server = "jsonls", cmd = { "@vscodelsp@/bin/vscode-json-language-server", "--stdio" } },
  -- yaml
  { server = "yamlls", cmd = { "@yamlls@/bin/yaml-language-server", "--stdio" } },
  -- vue
  { server = "vuels" },
  -- haskell
  { server = "hls" },
  -- nix
  { server = "rnix", cmd = { "@rnix@/bin/rnix-lsp" } },
  -- elixir
  { server = "elixirls", filetypes = { "elixir", "eelixir", "heex" } },
  -- python
  { server = "pyright" },
}

function plugin.on_attach(client, bufnr)
  local helper = require("helper")

  local function buf_keymap(mode, key, fn)
    vim.keymap.set(mode, key, fn, { buffer = bufnr })
  end

  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  local vl = vim.lsp.buf
  local vd = vim.lsp.diagnostic
  local tb = require("telescope.builtin")

  -- jump to
  buf_keymap("n", "gd", tb.lsp_definitions)
  buf_keymap("n", "gD", vl.declaration)
  buf_keymap("n", "gi", tb.lsp_implementations)
  buf_keymap("n", "gr", tb.lsp_references)
  buf_keymap("n", "<Leader>lD", vl.type_definition)
  buf_keymap("n", "[d", vd.goto_prev)
  buf_keymap("n", "]d", vd.goto_next)

  -- show info
  buf_keymap("n", "K", vl.hover)
  buf_keymap("n", "<C-K>", vl.signature_help)

  buf_keymap("n", "<Leader>lwl", function()
    print(vim.inspect(vl.list_workspace_folders))
  end)
  buf_keymap("n", "<Leader>lwa", vl.add_workspace_folder)
  buf_keymap("n", "<Leader>lwr", vl.remove_workspace_folder)

  -- edit
  buf_keymap("n", "<Leader>lf", vl.formatting)
  buf_keymap("n", "<Leader>lc", vl.code_action)
  buf_keymap("v", "<Leader>lc", vl.range_code_action)
  buf_keymap("n", "<Leader>lr", vl.rename)

  -- which key
  helper.registerPluginWk({
    prefix = "<leader>",
    buffer = bufnr,
    map = {
      l = {
        name = "LSP",
        D = "Type definition",
        f = "Format",
        c = "Code action",
        r = "Rename",
        w = {
          name = "Workspace",
          l = "List",
          a = "Add folder",
          r = "Remove folder",
        },
      },
    },
  })
  helper.registerPluginWk({
    prefix = "g",
    buffer = bufnr,
    map = {
      d = "Definitions",
      D = "Declaration",
      i = "Implementations",
      r = "References",
    },
  })
  helper.registerPluginWk({ prefix = "[", buffer = bufnr, map = { d = "Prev Diagnostic" } })
  helper.registerPluginWk({ prefix = "]", buffer = bufnr, map = { d = "Next Diagnostic" } })

  -- lsp signature
  require("lsp_signature").on_attach({
    bind = true,
    hint_prefix = "→ ",
  })
end

function plugin.getCapabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

  return capabilities
end

function plugin.config()
  local nvim_lsp = require("lspconfig")

  local onlyDiagnostics = vim.lsp.protocol.make_client_capabilities()
  onlyDiagnostics.textDocument = {
    publishDiagnostics = {
      relatedInformation = true,
      tagSupport = {
        valueSet = { 1, 2 },
      },
    },
  }

  local capabilities = plugin.getCapabilities()

  for _, lspdef in ipairs(servers) do
    local lsp = lspdef
    local cap = capabilities

    if type(lspdef) == "table" then
      local server = lspdef.server

      lspdef.server = nil

      if not lspdef.on_attach then
        lspdef.on_attach = plugin.on_attach
      end
      if not lspdef.capabilities then
        lspdef.capabilities = capabilities
      end

      nvim_lsp[server].setup(lspdef)
    else
      nvim_lsp[lsp].setup({
        on_attach = plugin.on_attach,
        capabilities = cap,
      })
    end
  end

  -- lua
  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  nvim_lsp.sumneko_lua.setup({
    on_attach = plugin.on_attach,
    capabilities = capabilities,
    cmd = { "@luals@/bin/lua-language-server" },
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Setup your lua path
          path = runtime_path,
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
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
  })
end

return plugin
