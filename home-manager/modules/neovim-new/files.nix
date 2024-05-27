{ pkgs, ... }: {
  name = "files";
  plugins = with pkgs.vimPlugins; [ nvim-web-devicons nvim-tree-lua ];
  config = # lua
    ''
      local t = require('nvim-tree')
      local ta = require('nvim-tree.api')

      local open_file = require("nvim-tree.actions.node.open-file").fn

      local function always_open(action)
        local node = ta.tree.get_node_under_cursor()

        open_file(action, node.absolute_path)
      end

      t.setup({
        disable_netrw = false,
        hijack_netrw = false,
        git = { enable = false },
        on_attach = function(bufnr)
          ta.config.mappings.default_on_attach(bufnr)

          local function setmap(key, cb, desc)
            vim.keymap.set("n", key, cb, { desc = "nvim-tree: " .. desc, buffer = bufnr })
          end

          setmap("O", function() always_open("edit") end, "Edit file and dir")
          setmap("<C-x>", function() always_open("split") end, "Split file and dir")
          setmap("<C-v>", function() always_open("vsplit") end, "Vsplit file and dir")
          setmap("<C-t>", function() always_open("tabnew") end, "Tabnew file and dir")
        end
      })

      vim.keymap.set("n", "<Leader>bb", ta.tree.toggle, { desc = "Toggle" })
      vim.keymap.set("n", "<Leader>bf", function() ta.tree.open({ find_file = true }) end, { desc = "Find file" })
      vim.keymap.set("n", "<Leader>b<", function() t.resize(-20) end, { desc = "Resize -20" })
      vim.keymap.set("n", "<Leader>b>", function() t.resize(20) end, { desc = "Resize +20" })

      Configs.common.wk_register({
        prefix = "<Leader>",
        map = { b = { name = "Nvim Tree" } }
      })
    '';
}
