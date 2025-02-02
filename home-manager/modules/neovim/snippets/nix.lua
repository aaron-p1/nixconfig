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

local file_name = function(pattern)
  return conds.make_condition(function()
    return vim.api.nvim_buf_get_name(0):match(pattern) ~= nil
  end)
end

ls.add_snippets("nix", {
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
