local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local sn = lsh.sn
local t = lsh.t
local i = lsh.i
local c = lsh.c
local fmta = lsh.fmta

local snips = {
  s(
    "fnga",
    fmta(
      [[
        public function get<>Attribute(<>)
        {
          return <>;
        }
      ]],
      {
        i(1, "ATTR"),
        c(2, {
          i(1),
          sn(1, {
            i(1),
            t("$value"),
          }),
        }),
        i(0),
      }
    )
  ),
  s(
    "fnsa",
    fmta(
      [[
        public function set<>Attribute(<>)
        {
          <>
        }
      ]],
      {
        i(1, "ATTR"),
        i(2, "$value"),
        i(0),
      }
    )
  ),
}

return snips
