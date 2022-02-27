local plugin = {}

function plugin.config()
  local nt = require("nvim-tree")

  nt.setup({
    disable_netrw = false,
    hijack_netrw = false,
  })

  local helper = require("helper")

  vim.keymap.set("n", "<Leader>bb", nt.toggle)
  vim.keymap.set("n", "<Leader>bf", function()
    nt.find_file(true)
  end)

  helper.registerPluginWk({
    prefix = "<leader>",
    map = {
      b = {
        name = "Nvim Tree",
        b = "Toggle",
        f = "Find file",
      },
    },
  })
end

return plugin
