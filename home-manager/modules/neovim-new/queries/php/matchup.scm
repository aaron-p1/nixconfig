(if_statement
  "if" @open.if) @scope.if

(else_if_clause "elseif" @mid.if.1)
(else_clause "else" @mid.if.2)

(method_declaration
  "function" @open.function) @scope.function

(anonymous_function
  "function" @open.function) @scope.function

(return_statement "return" @mid.function.1)

(method_declaration
  body: (compound_statement
          (_) @_return
          . "}" @close.function
          .)
  (#not-kind-eq? @_return "return_statement"))
