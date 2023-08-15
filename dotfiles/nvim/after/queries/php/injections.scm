;; extends

((string_value) @sql
  (#match? @sql "^(SELECT|INSERT|UPDATE|DROP)"))

(scoped_call_expression
  scope: (_) @_scope
  name: (_) @_name
  arguments: (arguments . (argument (string (string_value) @sql)))
  (#any-of? @_scope "\\DB" "DB")
  (#eq? @_name "raw"))

(scoped_call_expression
  name: (_) @_name
  arguments: (arguments . (argument (string (string_value) @sql)))
  (#any-of? @_name "selectRaw" "whereRaw"))

((string_value) @regex
  (#lua-match? @regex "^/?%^"))

((comment) @comment
  (#match? @comment "^/(/|\\*[^*])"))
