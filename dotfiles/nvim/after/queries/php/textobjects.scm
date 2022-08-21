(comment) @comment.outer

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
