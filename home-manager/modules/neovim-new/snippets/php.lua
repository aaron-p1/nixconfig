local ls = require("luasnip")
local extras = require("luasnip.extras")
local conds = require("luasnip.extras.conditions.expand")
local ts_postfix = require("luasnip.extras.treesitter_postfix").treesitter_postfix
local events = require("luasnip.util.events")

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
local ms = ls.multi_snippet

local cmp_callback = {
  [-1] = {
    [events.leave] = function()
      vim.schedule(function()
        Configs.completion.text_changed()
      end)
    end
  }
}

ls.add_snippets("php", {
  -- common
  s("t", t("true")),
  s("f", t("false")),
  s("if", fmta("if (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("ei", fmta("elseif (<>) {\n\t<>\n}", { i(1, "true"), i(0) })),
  s("el", fmta("else {\n\t<>\n}", i(0))),
  s("r", t("return")),

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
  }, { condition = -conds.line_begin })),
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

  -- conversions
  ts_postfix(
    {
      matchTSNode = {
        query = --[[ query ]] [[
          (anonymous_function_creation_expression
            parameters: (_) @params
            body: [
              (compound_statement
                . (return_statement (_) @body) .)
              (compound_statement
                . (expression_statement (_) @body) .)
            ]) @prefix
        ]],
        query_lang = "php"
      },
      trig = "c" -- for convert
    },
    fmt("fn {} => {}", {
      l(l.LS_TSCAPTURE_PARAMS),
      isn(1, l(l.LS_TSCAPTURE_BODY), ""),
    })
  ),
  ts_postfix(
    {
      matchTSNode = {
        query = --[[ query ]] [[
          (arrow_function
            parameters: (_) @params
            body: (_) @body) @prefix
        ]],
        query_lang = "php"
      },
      trig = "c" -- for convert
    },
    fmta("function <> {\n\t<>;\n}", {
      l(l.LS_TSCAPTURE_PARAMS),
      isn(1, l(l.LS_TSCAPTURE_BODY), "\t"),
    })
  ),
  ts_postfix(
    {
      matchTSNode = {
        query = --[[ query ]] [[
          (arrow_function
            parameters: (_) @params
            body: (_) @body) @prefix
        ]],
        query_lang = "php"
      },
      trig = "cr" -- for convert return
    },
    fmta("function <> {\n\treturn <>;\n}", {
      l(l.LS_TSCAPTURE_PARAMS),
      isn(1, l(l.LS_TSCAPTURE_BODY), "\t"),
    })
  ),

  -- auto snippets
  s({ trig = "this", snippetType = "autosnippet" }, t("$this")),

  -- dot alias
  ts_postfix(
    {
      matchTSNode = {
        query = --[[ query ]] [[
          [
            (variable_name)
            (function_call_expression)
            (member_access_expression)
            (member_call_expression)
          ] @prefix
        ]],
        query_lang = "php"
      },
      trig = ".",
      snippetType = "autosnippet",
    },
    isn(1, l(l.LS_TSMATCH .. "->"), ""),
    { callbacks = cmp_callback }
  ),
  s(
    {
      trig = "^(%s*)%.",
      trigEngine = "pattern",
      snippetType = "autosnippet",
    },
    f(function(_, parent)
      vim.print(parent.env)
      local linenr = parent.env.TM_LINE_NUMBER
      local prev_line = vim.api.nvim_buf_get_lines(0, linenr - 2, linenr - 1, false)[1] or ""
      local indent, after_indent = prev_line:match("^(%s*)(.*)")
      local indent_more = after_indent ~= ")" and not vim.startswith(after_indent, "->")
      local indent_suffix = indent_more and "\t" or ""
      return indent .. indent_suffix .. "->"
    end),
    { callbacks = cmp_callback }
  ),
  ts_postfix({
    matchTSNode = {
      query = --[[ query ]] [[
        (name) @prefix
      ]],
      query_lang = "php"
    },
    trig = ".",
    snippetType = "autosnippet",
  }, l(l.LS_TSMATCH .. "::"), { callbacks = cmp_callback }),
  ms({
      common = { snippetType = "autosnippet" },
      "parent.",
      "self.",
      "static.",
    },
    f(function(_, snip)
      return snip.trigger:match("%w+") .. "::"
    end),
    { callbacks = cmp_callback }
  ),
  ts_postfix({
    matchTSNode = {
      query = --[[ query ]] [[
        (array_element_initializer) @prefix
      ]],
      query_lang = "php"
    },
    trig = ":",
    snippetType = "autosnippet",
  }, l(l.LS_TSMATCH .. " =>")),
})
