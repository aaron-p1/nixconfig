local plugin = {}

function plugin.config()
  local wk = require("which-key")
  local helper = require("helper")

  wk.setup({})

  helper.registerPluginWk({
    prefix = "<leader>",
    map = {
      t = {
        name = "Tab",
      },
      r = {
        name = "Compare Remote Files",
        e = {
          name = "E",
          x = {
            name = "Ex",
            o = "Exo",
          },
        },
      },
    },
  })
end

return plugin
