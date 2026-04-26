local ls = require("luasnip")
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.conditions.expand")

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local isn = ls.indent_snippet_node
local c = ls.choice_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local n = extras.nonempty
local dl = extras.dynamic_lambda
local l = extras.lambda

ls.add_snippets("php", {
  -- common
  s("if", fmta("if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("ei", fmta("elseif (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("el", fmta("else {\n\t<>\n}", i(0))),
  s("r", t("return")),

  -- keywords
  s("pu", t("public ")),
  s("po", t("protected ")),
  s("pi", t("private ")),
  s("ab", t("abstract ")),
  s("st", t("static ")),

  -- functions
  s("puf", t("public function ")),
  s("pof", t("protected function ")),
  s("pif", t("private function ")),
  s("pusf", t("public static function ")),
  s("posf", t("protected static function ")),
  s("pisf", t("private static function ")),

  s("fn", fmta("<> function <>(<>)<><>\n{\n\t<>\n}", {
    c(1, { t("public"), t("protected"), t("private") }),
    i(2, "functionName"),
    i(3),
    n(4, ": "),
    i(4),
    i(0),
  }), { condition = conds.line_begin }),
  s("fn", fmta("function (<>) <><><>{\n\t<>\n}", {
    i(1),
    n(2, "use ("),
    i(2),
    n(2, ") "),
    i(0),
  }), { condition = -conds.line_begin }),
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

  -- auto snippets
  s({
    trig = "([(%[{ \t])this",
    wordTrig = false,
    trigEngine = "pattern",
    snippetType = "autosnippet",
    hidden = true
  }, { l(l.CAPTURE1), t("$this") }),

  -- dot alias
  s(
    {
      trig = "([^ \t()%[%]]*%S)%.",
      wordTrig = false,
      trigEngine = "pattern",
      snippetType = "autosnippet",
      hidden = true,
      resolveExpandParams = function(_, line, _, captures)
        local prefix = captures[1]

        -- if the prefix doesn't end with a valid character for method/field access, don't expand
        if not prefix:match("[a-zA-Z0-9_)%]]$") then
          return nil
        end

        -- not in string
        local count_single = select(2, line:gsub("'", ""))
        local count_double = select(2, line:gsub('"', ""))
        if (count_single % 2 == 1) or (count_double % 2 == 1) then
          return nil
        end

        -- if prefix is only numbers, it's likely a float, so don't expand
        if prefix:match("^[0-9]+$") then
          return nil
        end

        -- if it is not a variable, treat it as a class
        if prefix:match("^[a-zA-Z0-9_\\]+$") then
          return {trigger = ".", captures = {"::"}}
        end

        return {trigger = ".", captures = {"->"}}
      end
    },
    l(l.CAPTURE1)
  ),
  s(
    {
      trig = "^(%s*)%.",
      trigEngine = "pattern",
      snippetType = "autosnippet",
    },
    f(function(_, parent)
      local linenr = parent.env.TM_LINE_NUMBER
      local prev_line = vim.api.nvim_buf_get_lines(0, linenr - 2, linenr - 1, false)[1] or ""
      local indent, after_indent = prev_line:match("^(%s*)(.*)")
      local indent_more = after_indent ~= ")" and not vim.startswith(after_indent, "->")
      local indent_suffix = indent_more and "\t" or ""
      return indent .. indent_suffix .. "->"
    end)
  ),
  s({
    trig = "\\.",
    wordTrig = false,
    snippetType = "autosnippet",
    hidden = true
  }, t(".")),
})
