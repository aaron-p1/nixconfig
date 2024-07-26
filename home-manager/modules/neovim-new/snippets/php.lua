local ls = require("luasnip")
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.expand_conditions")

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local n = extras.nonempty
local dl = extras.dynamic_lambda
local l = extras.lambda

ls.add_snippets("php", {
  -- common
  s("th", t("$this->")),
  s("ei", fmta("elseif (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  -- keywords
  s("pu", t("public")),
  s("po", t("protected")),
  s("pi", t("private")),
  s("ab", t("abstract")),
  s("st", t("static")),
  -- functions
  s("ufn", t("public function ")),
  s("ofn", t("protected function ")),
  s("ifn", t("private function ")),
  s("fn", fmta("<> function <>(<>)<><>\n{\n\t<>\n}", {
    c(1, { t("public"), t("protected"), t("private") }),
    i(2, "functionName"),
    i(3),
    n(4, ": "),
    i(4),
    i(0),
  }, { condition = conds.line_begin })),
  s("fn", fmta("function (<>) <><><>{\n\t<>\n}", {
    i(1),
    n(2, "use ("),
    i(2),
    n(2, ") "),
    i(0),
  }, { condition = function(...) return not conds.line_begin(...) end })),
  s("fnn", fmta("fn (<>) =>> <>", { i(1), i(0) })),
  s("phpdoc", fmta("/**\n * <>\n */", i(0))),
  -- for
  s("fo", fmta("for (<> = <>; <> <>; <><>) {\n\t<>\n}", {
    i(1, "$i"),
    i(2, "0"),
    dl(3, l._1, 1),
    c(4, {
      t("< "),
      i(1, "10"),
      t("> "),
      i(1, "0"),
      i(nil),
      t("<= "),
      i(1, "10"),
      t(">= "),
      i(1, "0"),
    }),
    dl(5, l._1, 1),
    i(6, "++"),
    i(0),
  })),
  s("fe", fmta("foreach (<> as <>) {\n\t<>\n}", {
    i(1),
    c(2, { i(nil), sn(nil, fmt("{} => {}", { i(1), i(2) })) }),
    i(0),
  })),
})
