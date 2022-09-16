;; extends

(
  (comment) @_start .
  (method_declaration) @_end
  (#make-range! "fnwithdoc.outer" @_start @_end)
)

(array_creation_expression
  "," @_start .
  (_) @element.inner
  (#make-range! "element.outer" @_start @element.inner))
(array_creation_expression
  . (_) @element.inner
  . ","? @_end
  (#make-range! "element.outer" @element.inner @_end))

(assignment_expression
  "=" @_start .
  right: (_) @assignexpression.inner
  (#make-range! "assignexpression.outer" @_start @assignexpression.inner))

(binary_expression
  left: (_) @expression.inner .
  [
    "*"
    "%"
    "+"
    "-"
    "."
    ">>"
    "<<"
    ">"
    "<"
    ">="
    "<="
    "=="
    "==="
    "!="
    "!=="
    "<>"
    "<=>"
    "&"
    "^"
    "|"
    "&&"
    "||"
    "??"
    "instanceof"
  ] @_end
  (#make-range! "expression.outer" @expression.inner @_end))
(binary_expression
  [
    "*"
    "%"
    "+"
    "-"
    "."
    ">>"
    "<<"
    ">"
    "<"
    ">="
    "<="
    "=="
    "==="
    "!="
    "!=="
    "<>"
    "<=>"
    "&"
    "^"
    "|"
    "&&"
    "||"
    "??"
    "instanceof"
  ] @_start .
  right: (_) @expression.inner
  (#make-range! "expression.outer" @_start @expression.inner))
(binary_expression
  right: (_) @expression.inner)
(exponentiation_expression
  left: (_) @expression.inner .
  "**" @_end
  (#make-range! "expression.outer" @expression.inner @_end))
(exponentiation_expression
  "**" @_start .
  right: (_) @expression.inner
  (#make-range! "expression.outer" @_start @expression.inner))
(conditional_expression
  condition: (_) @expression.inner)
(conditional_expression
  body: (_) @expression.inner)
(conditional_expression
  alternative: (_) @expression.inner)

(anonymous_function_creation_expression
  body: (_) @function.inner) @function.outer

(if_statement
  condition: (parenthesized_expression
    (_) @conditional.inner))
(if_statement
  body: (_) @conditional.inner) @conditional.outer
(if_statement
  alternative: (_) @conditional.inner) @conditional.outer

(comment) @comment.outer
