local ls = require("luasnip")
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.conditions")
local ex_conds = require("luasnip.extras.expand_conditions")

local s = ls.snippet
local i = ls.insert_node
local rep = extras.rep
local fmta = require("luasnip.extras.fmt").fmta

---converts indentation to tabs
---@param str string
---@return string
local function to_fmt_string(str)
  return Configs.utils.indent_with_tab(Configs.utils.dedent(str), "  ")
end

local first_col = function(trigger)
  return conds.make_condition(function(line_to_cursor)
    return vim.startswith(trigger, line_to_cursor)
  end)
end

local first_line = conds.make_condition(function()
  return vim.api.nvim_win_get_cursor(0)[1] == 1
end)

local file_name = function(pattern)
  return conds.make_condition(function()
    return vim.api.nvim_buf_get_name(0):match(pattern) ~= nil
  end)
end

ls.add_snippets("nix", {
  s(
    "initflake",
    fmta(to_fmt_string( --[[ nix ]] [[
        {
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

          output = { self, nixpkgs }: {
            <>
          };
        }
      ]]),
      { i(0) }
    ), {
      condition = first_line * first_col("initflake") * file_name("flake.nix"),
      show_condition = first_line * first_col("initflake") * file_name("flake.nix")
    }
  ),
  s(
    "devshell",
    fmta(to_fmt_string( --[[ nix ]] [[
        devShells.<arch>.default = let
          pkgs = import nixpkgs { system = "<archrep>"; };
        in
          pkgs.mkShell {
            buildInputs = [
              <last>
            ];
          };
      ]]),
      {
        arch = i(1, "x86_64-linux"),
        archrep = rep(1),
        last = i(0)
      }
    ), {
      condition = ex_conds.line_begin * file_name("flake.nix"),
      show_condition = file_name("flake.nix")
    }
  )
})
