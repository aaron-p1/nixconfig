{ pkgs, ... }: {
  name = "snippets";
  plugins = with pkgs.vimPlugins; [ luasnip ];
  config = # lua
    ''
      local ls = require("luasnip")
      local lt = require("luasnip.util.types")

      vim.keymap.set("i", "<C-k>", ls.expand, { desc = "Expand" })
      vim.keymap.set({ "i", "s" }, "<C-j>", function() return ls.jump(-1) end, { desc = "Prev" })
      vim.keymap.set({ "i", "s" }, "<C-l>", function() return ls.jump(1) end, { desc = "Next" })
      vim.keymap.set("n", "<Leader>i", ls.unlink_current, { desc = "Unlink snippet" })
      vim.keymap.set({ "i", "s" }, "<C-e>", function()
        return ls.choice_active() and "<Plug>luasnip-next-choice" or "<C-e>"
      end, { expr = true, desc = "Next choice" })

      ls.setup({
        update_events = { "TextChanged", "TextChangedI" },
        region_check_events = { "InsertEnter" },
        ext_opts = {
          [lt.choiceNode] = {
            active = { virt_text = { { "●", "LuasnipChoiceActive" } } },
            visited = { virt_text = { { "✔️", "LuasnipChoiceVisited" } } },
            unvisited = { virt_text = { { "⨉", "LuasnipChoiceUnvisited" } } },
          },
          [lt.insertNode] = {
            active = { virt_text = { { "●", "LuasnipInsertActive" } } },
            visited = { virt_text = { { "✔️", "LuasnipInsertVisited" } } },
            unvisited = { virt_text = { { "⨉", "LuasnipInsertUnvisited" } } },
          },
        },
      })

      return {
        lsp_expand = ls.lsp_expand
      }
    '';
}
