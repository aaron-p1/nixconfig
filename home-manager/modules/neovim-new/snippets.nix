# https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
{ pkgs, lib, ... }:
let
  inherit (builtins) readDir mapAttrs readFile;
  inherit (lib) pipe filterAttrs replaceStrings mapAttrsToList concatStringsSep;

  extraSnippetFiles = pipe ./snippets [
    readDir
    (filterAttrs (_: v: v == "regular"))
    (mapAttrs (file: _: readFile (./snippets + "/${file}")))
  ];

  withoutExtension = replaceStrings [ ".lua" ] [ "" ];

  luaContent = pipe extraSnippetFiles [
    (mapAttrsToList (file: _: # lua
      "require('my_snippets.${withoutExtension file}')"))
    (concatStringsSep "\n")
  ];
in {
  name = "snippets";
  plugins = with pkgs.vimPlugins; [ luasnip ];
  luaPackages = ps: [ ps.jsregexp ];
  extraFiles.lua.my_snippets = extraSnippetFiles;
  config = # lua
    ''
      local ls = require("luasnip")
      local le = require("luasnip.extras")
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

      ---run command and return stdout lines
      ---@param command string[]
      ---@return string[]
      local function run_in_shell(command)
        local stdout = vim.system(command):wait().stdout

        if not stdout then
          return {}
        end

        local lines = vim.split(stdout, "\n")

        if lines[#lines] == "" then
          table.remove(lines, #lines)
        end

        return lines
      end

      ---create simple shell command snippet
      ---@param trig string
      ---@param command string[]
      local function shell_snippet(trig, command)
        return ls.snippet(trig, le.partial(run_in_shell, command))
      end

      ls.add_snippets("all", {
        shell_snippet("uuidgen", { "uuidgen" }),
        shell_snippet("date", { "date", "--iso-8601" }),
        shell_snippet("datetime", { "date", "--rfc-3339=seconds" }),
        shell_snippet("datetimei", { "date", "--iso-8601=seconds" }),
      })

      ${luaContent}

      return {
        lsp_expand = ls.lsp_expand
      }
    '';
}
