;; extends

((comment) @injection.language
  .
  [
    (binary_expression
      left: [
        (string_expression
          (string_fragment) @injection.content)
        (indented_string_expression
          (string_fragment) @injection.content)
      ])
    (binary_expression
      left: (binary_expression
        left: [
          (string_expression
            (string_fragment) @injection.content)
          (indented_string_expression
            (string_fragment) @injection.content)
        ]))
  ]
  (#gsub! @injection.language "#%s*([%w%p]+)%s*" "%1")
  (#set! injection.combined))
