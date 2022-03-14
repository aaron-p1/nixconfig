local helper = require("plugins.my-luasnip.helper")

local s = helper.s
local i = helper.i
local t = helper.t
local fmta = helper.fmta

local snips = {
  s("t", t("true")),
  s("f", t("false")),
  s("if", fmta("if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("ei", fmta("else if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("el", fmta("else {\n\t<>\n}", i(0))),
}

return snips
