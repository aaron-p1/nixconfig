local ls = require("luasnip")

-- LuaSnip
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")

local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta

local conds = require("luasnip.extras.expand_conditions")

-- Helper
-- conditions
local function firstLine()
  return vim.fn.line(".") == 1
end

local function firstInFile(line_to_cursor, matched_trigger)
  return firstLine() and line_to_cursor == matched_trigger
end

return {
  ls = ls,
  s = s,
  sn = sn,
  isn = isn,
  t = t,
  i = i,
  f = f,
  c = c,
  d = d,
  r = r,
  events = events,
  ai = ai,

  l = l,
  rep = rep,
  p = p,
  m = m,
  n = n,
  dl = dl,
  fmt = fmt,
  fmta = fmta,

  conds = conds,

  firstLine = firstLine,
  firstInFile = firstInFile,
}
