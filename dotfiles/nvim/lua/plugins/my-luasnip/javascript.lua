local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local i = lsh.i
local m = lsh.m
local fmt = lsh.fmt
local fmta = lsh.fmta

local snips = {
  s(
    "lb",
    fmt("{}{}{} => {}", {
      m(1, ",", "("),
      i(1),
      m(1, ",", ")"),
      i(0),
    })
  ),
  s(
    "fn",
    fmta("function (<>) {\n\t<>\n}", {
      i(1),
      i(0),
    })
  ),
}

return snips
