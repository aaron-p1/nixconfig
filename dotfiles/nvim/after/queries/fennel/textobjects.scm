;; extends

(sequential_table
  (_) @element.inner @element.outer)

(table
  ((_) . (_))* .
  (_) @_start .
  (_) @_end
  (#make-range! "element.outer" @_start @_end)
  (#make-range! "element.inner" @_start @_end))

(table_binding
  ([(_) ":"] . (_))* .
  [(_) ":"] @_start .
  (_) @_end
  (#make-range! "element.outer" @_start @_end)
  (#make-range! "element.inner" @_start @_end))
