{ pkgs, ... }: {
  name = "common";
  plugins = with pkgs.vimPlugins; [
    vim-repeat
    vim-abolish
    vim-unimpaired
    nvim-surround
    which-key-nvim
  ];
  config = # lua
    ''
      local enabled_spell_langs = { "de", "en" }

      local function enable_spell()
        vim.ui.select(
          enabled_spell_langs,
          { prompt = "Select spelllang" }, function(choice)
            if choice ~= nil then
              vim.opt_local.spelllang = choice
              vim.opt_local.spellfile = Configs.base.spelldir .. '/' .. choice .. '.utf-8.add'
              vim.opt_local.spell = true
            end
          end)
      end

      vim.keymap.set("n", "[os", enable_spell, { desc = "Enable spell" })
      vim.keymap.set("n", "yos", function()
        if vim.o.spell then
          vim.opt_local.spell = false
        else
          enable_spell()
        end
      end, { desc = "Toggle spell" })

      require('nvim-surround').setup({
        highlight = { duration = 0 },
        move_cursor = false,
        indent_lines = false,
      })

      local wk = require("which-key")
      wk.setup({
        disable = { filetypes = { "TelescopePrompt", "DressingInput" } }
      })
      local function wk_register(config)
        wk.register(config.map, {
          prefix = config.prefix or "",
          buffer = config.buffer
        })
      end

      return { wk_register = wk_register }
    '';
}
