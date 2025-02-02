;; extends

((string_content) @injection.content
  (#match? @injection.content "^(SELECT|INSERT|UPDATE|DROP)")
  (#set! injection.language "sql"))

(scoped_call_expression
  scope: (_) @_scope
  name: (_) @_name
  arguments: (arguments . (argument (string (string_content) @injection.content)))
  (#any-of? @_scope "\\DB" "DB")
  (#eq? @_name "raw")
  (#set! injection.language "sql"))

(scoped_call_expression
  name: (_) @_name
  arguments: (arguments . (argument (string (string_content) @injection.content)))
  (#any-of? @_name "selectRaw" "whereRaw")
  (#set! injection.language "sql"))

((string_content) @injection.content
  (#lua-match? @injection.content "^/?%^")
  (#set! injection.language "regex"))
