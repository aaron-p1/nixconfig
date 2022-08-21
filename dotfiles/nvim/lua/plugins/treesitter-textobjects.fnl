(local {: register_plugin_wk} (require :helper))

(fn config []
  (local tsc (require :nvim-treesitter.configs))
  (tsc.setup {:textobjects {:select {:enable true
                                     :lookahead true
                                     :include_surrounding_whitespace true
                                     :keymaps {; custom
                                               :aF "@fnwithdoc.outer"
                                               :ae "@element.outer"
                                               :ie "@element.inner"
                                               ; builtin
                                               :af "@function.outer"
                                               :if "@function.inner"
                                               :aa "@parameter.outer"
                                               :ai "@parameter.inner"
                                               :al "@loop.outer"
                                               :il "@loop.inner"
                                               :ao "@conditional.outer"
                                               :io "@conditional.inner"
                                               :ac "@comment.outer"}}
                            :move {:enable true
                                   :set_jumps true
                                   :goto_previous_start {"[m" "@function.outer"}
                                   :goto_previous_end {"[M" "@function.outer"}}
                                   :goto_next_start {"]m" "@function.outer"}
                                   :goto_next_end {"]M" "@function.outer"}
                            :swap {:enable true
                                   :swap_next {:<Leader>sa "@parameter.inner"
                                               :<Leader>sf "@function.outer"}
                                   :swap_previous {:<Leader>sA "@parameter.inner"
                                                   :<Leader>sF "@function.outer"}}}})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:s {:name :Swap
                                 :a "Argument forwards"
                                 :A "Argument backwards"
                                 :f "Function forward"
                                 :F "Function backwards"}}}))

{: config}
