{ pkgs, nvimUtil, ... }:
{
  within.neovim.configDomains.db = {
    overlay = nvimUtil.pluginOverlay (
      { pvP, ... }:
      {
        vim-dadbod = pvP.vim-dadbod.overrideAttrs (old: {
          patches = [ ./patches/dadbod-fix-output-newlines.patch ];
        });
      }
    );
    plugins = with pkgs.vimPlugins; [
      vim-dadbod
      vim-dadbod-ui
    ];
    packages = with pkgs; [ mariadb ];
    config = # lua
      ''
        ---@param lines table[]
        function Db_fix_lines(lines)
          for i = 2, #lines do
            local line = lines[i]

            if line == nil then
              break
            end

            local last_char = line:sub(-1)

            while string.match(last_char or "", "[^|+]") do
              local next_line = lines[i + 1]

              if next_line == nil then
                break
              end

              lines[i] = lines[i] .. '⬇️' .. next_line

              table.remove(lines, i + 1)

              last_char = lines[i]:sub(-1)
            end
          end

          return lines
        end

        -- e.g. default=mysql://...,extra=postgresql://...
        local db_strings = vim.env.NVIM_DB_STRINGS or vim.env.NVIM_DB_STRING
        local db_strings_table = {}

        if db_strings and db_strings ~= "" then
          local default_count = 0

          for _, db_string in ipairs(vim.split(db_strings, ",", { trimempty = true })) do
            local name, db = string.match(db_string, "^([^=]+)=?(.*)$")
            local parts = vim.split(db_string, "=", { trimempty = true })

            if db == "" then
              name = nil
              db = parts[1]
            end

            if not name then
              default_count = default_count + 1

              name = "default_" .. default_count
            end

            if db:match("^%a+://") then
              db_strings_table[name] = db
            else
              vim.notify("Invalid NVIM_DB_STRINGS format: '" .. db_string .. "'", vim.log.levels.ERROR)
            end
          end

          vim.g.dbs = db_strings_table
        end

        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/dbui'

        vim.keymap.set("n", "<Leader>D", "<Cmd>tab DBUI<CR>", { silent = true, desc = "Open DBUI" })

        vim.api.nvim_create_autocmd("FileType", {
          pattern = { "dbout" },
          callback = function()
            vim.opt_local.spell = false
          end
        })
      '';
  };
}
