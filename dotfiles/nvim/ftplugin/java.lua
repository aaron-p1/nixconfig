local j = require('jdtls')
local helper = require('helper')
local lspconfig = require("plugins.lspconfig")

local function on_attach(client, bufnr)
  lspconfig.on_attach(client, bufnr);

  require('jdtls.setup').add_commands()

  local function buf_keymap(mode, key, fn)
      vim.keymap.set(mode, key, fn, {buffer = bufnr})
  end


  buf_keymap('n', '<Leader>llo', j.organize_imports)
  buf_keymap('n', '<Leader>llv', j.extract_variable)
  buf_keymap('v', '<Leader>llv', function () j.extract_variable(true) end)
  buf_keymap('n', '<Leader>llc', j.extract_constant)
  buf_keymap('v', '<Leader>llc', function () j.extract_constant(true) end)
  buf_keymap('v', '<Leader>llm', function () j.extract_method(true) end)

  -- which key
  helper.registerPluginWk{
    prefix = '<leader>',
    buffer = bufnr,
    map = {
      l = {
        l = {
          name = 'Java',
          o = 'Organize imports',
          v = 'Extract variable',
          c = 'Extract Constant',
          m = 'Extract Method',
        }
      },
    },
  }

  -- TODO debugging
end

local config = {
  cmd = {
	  '@jdtls@/bin/jdt-language-server'
  },

  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

  capabilities = lspconfig.getCapabilities(),
  extendedClientCapabilities = require("jdtls").extendedClientCapabilities,
  on_attach = on_attach
}

j.start_or_attach(config)
