# https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
{ pkgs, lib, ... }:
let
  inherit (builtins)
    readDir mapAttrs readFile match split filter isString elemAt listToAttrs
    head tail;
  inherit (lib)
    pipe filterAttrs mapAttrsToList concatStringsSep splitString optional;

  snippetScopeName = "my_snippets";

  extraSnippetFiles = pipe ./snippets [
    readDir
    (filterAttrs (_: v: v == "regular"))
    (mapAttrs (file: _: ./snippets + "/${file}"))
  ];

  withoutExtension = file:
    let base = match "(.*)([.].*)" file;
    in if base == null then file else head base;

  luaContent = pipe extraSnippetFiles [
    (mapAttrsToList (file: _: # lua
      "require('${snippetScopeName}.${withoutExtension file}')"))
    (concatStringsSep "\n")
  ];

  parseOptionLine = line:
    pipe line [
      (split "[[:blank:]]+")
      (filter (s: isString s && s != ""))
      tail
      (map (splitString "="))
      (map (parts: {
        name = elemAt parts 0;
        value = elemAt parts 1;
      }))
      listToAttrs
    ];

  readInitSnippetFiles = dir:
    pipe dir [
      readDir
      (filterAttrs (file: v: v == "regular"))
      (mapAttrsToList (file: _:
        let
          content = readFile (dir + "/${file}");
          contentMatches = match ''
            (# [^
            ]+)?
            ?(.*)'' content;

          optionLine = elemAt contentMatches 0;
        in {
          trig = withoutExtension file;
          options =
            if optionLine == null then { } else parseOptionLine optionLine;
          snippet = elemAt contentMatches 1;
        }))
    ];

  toLuaString = s: ''"${s}"'';

  toLuaTable = attrs:
    let
      toLuaValue = v:
        if isString v then v else lib.throw "Unsupported value type";
      elems = (mapAttrsToList (k: v: "${k} = ${toLuaValue v}") attrs);
    in "{ ${concatStringsSep ", " elems} }";

  toSnippetLines = map (s:
    let
      trig = "init${s.trig}";

      conditions = [ "first_line" ''first_col("${trig}")'' ]
        ++ optional (s.options ? file) ''file_name("${s.options.file}")'';

      conditionLine = concatStringsSep " * " conditions;

      snippetOptions = {
        trig = toLuaString trig;
        condition = conditionLine;
        show_condition = conditionLine;
      };

      # lua
    in ''
      ls.parser.parse_snippet(${
        toLuaTable snippetOptions
      }, [===[${s.snippet}]===])
    '');

  initSnippetLuaCode = pipe ./snippets/init [
    readDir
    (filterAttrs (_: v: v == "directory"))
    (mapAttrs (file: _: ./snippets/init + "/${file}"))

    (mapAttrs (_: path: readInitSnippetFiles path))

    # { ft = {trig = ""; options = { }; snippet = "" } }

    (mapAttrsToList (ft: snippets:
      # lua
      ''
        ls.add_snippets("${ft}", {
          ${
            concatStringsSep ''
              ,
            '' (toSnippetLines snippets)
          }
        })
      ''))

    (concatStringsSep "\n")

    (snippets: # lua
      ''
        do
          local conds = require("luasnip.extras.conditions")

          local function first_col(trigger)
            return conds.make_condition(function(line_to_cursor)
              return vim.startswith(trigger, line_to_cursor)
            end)
          end

          local first_line = conds.make_condition(function()
            return vim.api.nvim_win_get_cursor(0)[1] == 1
          end)

          local function file_name(pattern)
            return conds.make_condition(function()
              return vim.api.nvim_buf_get_name(0):match(pattern) ~= nil
            end)
          end

          ${snippets}
        end
      '')
  ];
in {
  name = "snippets";
  plugins = with pkgs.vimPlugins; [ luasnip ];
  extraFiles.lua.${snippetScopeName} = extraSnippetFiles;
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
        enable_autosnippets = true,
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

      ${initSnippetLuaCode}

      return {
        lsp_expand = ls.lsp_expand
      }
    '';
}
