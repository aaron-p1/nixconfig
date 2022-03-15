local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local i = lsh.i
local fmta = lsh.fmta

local snips = {
  s("os", fmta('"<>": "<>"', { i(1), i(2) })),
  s("osc", fmta('"<>": "<>",', { i(1), i(2) })),
}

return snips
