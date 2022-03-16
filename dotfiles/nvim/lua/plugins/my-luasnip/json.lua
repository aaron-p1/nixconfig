local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local i = lsh.i
local t = lsh.t
local fmta = lsh.fmta

local mc = lsh.mc
local ac = lsh.ac

local typeTable = {
  t = t("true"),
  f = t("false"),
  n = t(""),
  s = fmta('"<>"', i(1)),
  a = fmta("[\n\t<>\n]", i(1)),
  o = fmta("{\n\t<>\n}", i(1)),
}

local snips = {
  s("t", t("true")),
  s("f", t("false")),
  s({ trig = "o([tfnsao])(c?)", regTrig = true }, fmta('"<>": <><>', { i(1), ac(2, 1, typeTable), mc(2, ",") })),
  s({ trig = "a([tfsao])(c?)", regTrig = true }, fmta('<><>', { ac(2, 1, typeTable), mc(2, ",") })),
}

return snips
