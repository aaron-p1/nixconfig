(list_expression
  element: (_) @element.inner @element.outer
)
(binding) @element.outer
(binding
  attrpath: (_) @_start
  expression: (_) @_end
  (#make-range! "element.inner" @_start @_end)
)

(binding
  "=" @_start
  expression: (_) @assignexpression.inner
  (#make-range! "assignexpression.outer" @_start @assignexpression.inner)
)

(function_expression) @function.outer
(function_expression
  body: (_) @function.inner
)

(apply_expression
  argument: (_) @parameter.inner @parameter.outer
)

(if_expression) @conditional.outer
(if_expression
  consequence: (_) @conditional.inner
)
(if_expression
  alternative: (_) @conditional.inner
)

(comment) @comment.outer

