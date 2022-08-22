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

(if_statement
  condition: (parenthesized_expression
    (_) @conditional.inner))
(if_statement
  body: (_) @conditional.inner) @conditional.outer
(if_statement
  alternative: (_) @conditional.inner) @conditional.outer

(comment) @comment.outer
