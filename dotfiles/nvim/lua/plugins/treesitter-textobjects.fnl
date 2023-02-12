(local {:register wk-register} (require :plugins.which-key))

(local {: setup} (require :nvim-treesitter.configs))

(fn config []
  (setup {:textobjects {:select {:enable true
                                 :lookahead false
                                 :include_surrounding_whitespace true
                                 :keymaps {; custom
                                           :aF "@fnwithdoc.outer"
                                           :ae "@element.outer"
                                           :ie "@element.inner"
                                           :i= "@assignexpression.inner"
                                           :a= "@assignexpression.outer"
                                           :ix "@expression.inner"
                                           :ax "@expression.outer"
                                           ; builtin
                                           :af "@function.outer"
                                           :if "@function.inner"
                                           :aa "@parameter.outer"
                                           :ia "@parameter.inner"
                                           :al "@loop.outer"
                                           :il "@loop.inner"
                                           :ao "@conditional.outer"
                                           :io "@conditional.inner"
                                           :ac "@comment.outer"}}
                        :move {:enable true
                               :set_jumps true
                               :goto_previous_start {"[m" "@function.outer"}
                               :goto_previous_end {"[M" "@function.outer"}
                               :goto_next_start {"]m" "@function.outer"}
                               :goto_next_end {"]M" "@function.outer"}}
                        :swap {:enable true
                               :swap_next {:<Leader>sa "@parameter.inner"
                                           :<Leader>sf "@function.outer"}
                               :swap_previous {:<Leader>sA "@parameter.inner"
                                               :<Leader>sF "@function.outer"}}}})
  (wk-register {:prefix :<Leader>
                :map {:s {:name :Swap
                          :a "Argument forwards"
                          :A "Argument backwards"
                          :f "Function forward"
                          :F "Function backwards"}}}))

{: config}
