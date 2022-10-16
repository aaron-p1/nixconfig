;; extends

(sequential_table
  (_) @element.inner @element.outer)

(table
  ((_) . (_))* .
  (_) .
  (_) @element.inner)

(table
  ((_) . (_))* .
  (_) @_start .
  (_) @_end
  (#make-range! "element.outer" @_start @_end))
