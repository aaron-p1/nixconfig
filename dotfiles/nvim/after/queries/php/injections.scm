;; extends

((string_value) @sql
  (#match? @sql "^(SELECT|INSERT|UPDATE|DROP)"))

((string_value) @regex
  (#lua-match? @regex "^/?%^"))

((comment) @comment
  (#match? @comment "^/(/|\\*[^*])"))
