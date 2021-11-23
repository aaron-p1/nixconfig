local helper = require('helper')
local lspconfig = require("plugins.lspconfig")

local function on_attach(client, bufnr)
  lspconfig.on_attach(client, bufnr);

  local function keymap_jdtls_leader_n(key, action)
    helper.keymap_b_lua_leader_n_ns(bufnr, key, [[require('jdtls').]] .. action)
  end

  local function keymap_jdtls_leader_v(key, action)
    vim.api.nvim_buf_set_keymap(
      bufnr,
      'v',
      '<leader>' .. key, [[<Esc><Cmd>lua require('jdtls').]] .. action .. '<CR>',
      {
        noremap = true,
        silent = true,
      })
  end

  keymap_jdtls_leader_n('lc', 'code_action()')
  keymap_jdtls_leader_v('lc', 'code_action(true)')

  keymap_jdtls_leader_n('llo', 'organize_imports()')
  keymap_jdtls_leader_n('llv', 'extract_variable()')
  keymap_jdtls_leader_v('llv', 'extract_variable(true)')
  keymap_jdtls_leader_n('llc', 'extract_constant()')
  keymap_jdtls_leader_v('llc', 'extract_constant(true)')
  keymap_jdtls_leader_v('llm', 'extract_method(true)')

  -- which key
  helper.registerPluginWk{
    prefix = '<leader>',
    buffer = bufnr,
    map = {
      l = {
        l = {
          name = 'Java',
        }
      },
    },
  }

  -- TODO debugging
end

local config = {
  cmd = {
	  'jdt-language-server'
  },

  root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),

  capabilities = lspconfig.getCapabilities(),
  on_attach = on_attach
}

require('jdtls').start_or_attach(config)
