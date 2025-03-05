{ pkgs, ... }: {
  within.neovim.configDomains.which_key = {
    plugins = with pkgs.vimPlugins; [ which-key-nvim ];
    config = # lua
      ''
        local wk = require("which-key")

        wk.setup({
          disable = { filetypes = { "TelescopePrompt", "DressingInput" } }
        })

        local function add(mappings, template)
          template = template or {}

          -- apply template values
          for _, mapping in ipairs(mappings) do
            for key, value in pairs(template) do
              if key == 1 then
                if mapping[1] then
                  mapping[1] = value .. mapping[1]
                end
              else
                mapping[key] = mapping[key] or value
              end
            end
          end

          wk.add(mappings)
        end

        return { add = add }
      '';
  };
}
