(if_statement
  "if" @open.if) @scope.if

(else_if_clause "elseif" @mid.if.1)
(else_clause "else" @mid.if.2)

(method_declaration
  "function" @open.function) @scope.function

(anonymous_function_creation_expression
  "function" @open.function) @scope.function

(return_statement) @mid.function.1
