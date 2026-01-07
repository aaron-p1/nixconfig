;; extends

(list_expression
  element: (_) @element.inner @element.outer
)
(binding) @element.outer
; (binding
;   attrpath: (_) @_start
;   expression: (_) @_end
;   (#make-range! "element.inner" @_start @_end)
; )

; (formals
;   "," @_start .
;   (formal) @element.inner
;   (#make-range! "element.outer" @_start @element.inner))
; (formals
;   . (formal) @element.inner
;   . ","? @_end
;   (#make-range! "element.outer" @element.inner @_end))

; (binding
;   "=" @_start
;   expression: (_) @assignexpression.inner
;   (#make-range! "assignexpression.outer" @_start @assignexpression.inner)
; )

(if_expression
  alternative: (_) @conditional.inner
)
