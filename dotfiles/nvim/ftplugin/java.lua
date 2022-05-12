local j = require("jdtls")
local helper = require("helper")
local lspconfig = require("plugins.lspconfig")

local function on_attach(client, bufnr)
  lspconfig.on_attach(client, bufnr)

  require("jdtls.setup").add_commands()

  local function buf_keymap(mode, key, fn, opts)
    if opts == nil then
      opts = {}
    end

    opts.buffer = bufnr

    vim.keymap.set(mode, key, fn, opts)
  end

  buf_keymap("n", "<Leader>llo", j.organize_imports, {desc = "Organize imports"})
  buf_keymap("n", "<Leader>llv", j.extract_variable, {desc = "Extract variable"})
  buf_keymap("v", "<Leader>llv", function()
    j.extract_variable(true)
  end, {desc = "Extract variable"})
  buf_keymap("n", "<Leader>llc", j.extract_constant, {desc = "Extract constant"})
  buf_keymap("v", "<Leader>llc", function()
    j.extract_constant(true)
  end, {desc = "Extract constant"})
  buf_keymap("v", "<Leader>llm", function()
    j.extract_method(true)
  end, {desc = "Extract Method"})

  -- which key
  helper.registerPluginWk({
    prefix = "<leader>",
    buffer = bufnr,
    map = {
      l = {
        l = {
          name = "Java",
        },
      },
    },
  })

  -- TODO debugging
end

local config = {
  cmd = {
    "jdt-language-server",
  },

  root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

  capabilities = lspconfig.getCapabilities(),
  extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
  on_attach = on_attach,
}

j.start_or_attach(config)
