local plugin = {}

function plugin.config()
  local ls = require("luasnip")
  local fun = require("fun")
  local helper = require("helper")

  vim.keymap.set("n", "<leader>rpls", function()
    package.loaded["plugins.luasnip"] = nil

    fun.iter(package.loaded)
      :map(function(k, _)
        return k
      end)
      :filter(function(k)
        return k:find("^plugins[.]my-luasnip[.]") ~= nil
      end)
      :each(function(k)
        package.loaded[k] = nil
      end)

    require("plugins.luasnip").config()
  end)

  vim.keymap.set("i", "<C-K>", ls.expand)
  vim.keymap.set({ "i", "s" }, "<C-J>", function()
    ls.jump(-1)
  end)
  vim.keymap.set({ "i", "s" }, "<C-L>", function()
    ls.jump(1)
  end)

  vim.keymap.set("n", "<leader>i", function()
    ls.unlink_current()
  end)

  vim.keymap.set({ "i", "s" }, "<C-E>", function()
    return ls.choice_active() and "<Plug>luasnip-next-choice" or "<C-E>"
  end, { expr = true, remap = true })

  helper.registerPluginWk({
    prefix = "<leader>",
    map = {
      i = "Unlink snip",
      r = {
        name = "Reload",
        p = {
          name = "Plugin",
          l = {
            name = "L",
            s = "LuaSnip",
          },
        },
      },
    },
  })

  local types = require("luasnip.util.types")

  ls.config.set_config({
    updateevents = "TextChanged,TextChangedI",
    region_check_events = "InsertEnter",
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { "●", "GruvboxOrange" } },
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { "●", "GruvboxBlue" } },
        },
      },
    },
  })

  local snippet_groups = fun.iter({
    "all",
    "c_like",
    "html",
    "php",
    "laravel",
    "blade",
  })
    :map(function(v)
      return v, require("plugins.my-luasnip." .. v)
    end)
    :tomap()

  local group_assignments = {
    all = { "all" },
    html = { "html" },
    php = { "php", "c_like", "laravel" },
    blade = { "blade", "html" },
  }

  ls.snippets = fun.iter(group_assignments)
    :map(function(ft, groups)
      return ft,
        fun.iter(groups)
          :map(function(group)
            return snippet_groups[group]
          end)
          :foldl(function(acc, val)
            return fun.chain(acc, val)
          end, {})
          :totable()
    end)
    :tomap()
end

return plugin
