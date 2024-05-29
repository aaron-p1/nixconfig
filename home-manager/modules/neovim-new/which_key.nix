{ pkgs, ... }: {
  name = "which_key";
  plugins = with pkgs.vimPlugins; [ which-key-nvim ];
  config = # lua
    ''
      local wk = require("which-key")

      wk.setup({
        disable = { filetypes = { "TelescopePrompt", "DressingInput" } }
      })

      local function register(config)
        wk.register(config.map, {
          prefix = config.prefix or "",
          buffer = config.buffer
        })
      end

      return { register = register }
    '';
}
