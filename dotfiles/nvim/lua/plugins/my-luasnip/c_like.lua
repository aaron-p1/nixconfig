local helper = require("plugins.my-luasnip.helper")

local s = helper.s
local i = helper.i
local fmta = helper.fmta

local snips = {
  s("if", fmta("if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("ei", fmta("else if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("el", fmta("else {\n\t<>\n}", i(0))),
}

return snips
