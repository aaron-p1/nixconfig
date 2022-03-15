local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local i = lsh.i
local t = lsh.t
local fmta = lsh.fmta

local snips = {
  s("t", t("true")),
  s("f", t("false")),
  s("if", fmta("if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("ei", fmta("else if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("el", fmta("else {\n\t<>\n}", i(0))),
  s("r", fmta("return <>;", i(0))),
}

return snips
