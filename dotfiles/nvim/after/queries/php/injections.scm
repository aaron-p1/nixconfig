((string_value) @sql
  (#match? @sql "^(SELECT|INSERT|UPDATE|DROP)"))

((comment) @comment
  (#match? @comment "^/(/|\\*[^*])"))
