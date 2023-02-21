(local {: startswith :keymap {:set kset}} vim)

(local {: replace_tc} (require :helper))
(local {:register wk-register} (require :plugins.which-key))

(local {: setup
        :expand ls-expand
        :jump ls-jump
        :unlink_current ls-unlink
        : choice_active} (require :luasnip))

(local {:choiceNode choice-node :insertNode insert-node}
       (require :luasnip.util.types))

(local {: from_cursor_pos} (require :luasnip.extras.filetype_functions))

(local {: load_snippets} (require :plugins.luasnip.snippets))

(fn config []
  (kset :n :<Leader>rpl
        (fn []
          (tset package.loaded :plugins.luasnip nil)
          (each [p _ (pairs package.loaded)]
            (when (startswith p :plugins.luasnip.)
              (tset package.loaded p nil)))) {:desc :Luasnip})
  (kset :i :<C-K> ls-expand {:desc :Expand})
  (kset [:i :s] :<C-J> #(ls-jump -1) {:desc :Prev})
  (kset [:i :s] :<C-L> #(ls-jump 1) {:desc :Next})
  (kset :n :<Leader>i ls-unlink {:desc "Unlink snip"})
  (kset [:i :s] :<C-E> #(if (choice_active) :<Plug>luasnip-next-choice :<C-E>)
        {:expr true :desc "Next choice"})
  (wk-register {:prefix :<Leader> :map {:r {:name :Reload :p {:name :Plugin}}}})
  (setup {:update_events [:TextChanged :TextChangedI]
          :region_check_events :InsertEnter
          :ft_func from_cursor_pos
          :load_ft_func from_cursor_pos
          :ext_opts {choice-node {:active {:virt_text [["●" :GruvboxOrange]]}}
                     insert-node {:active {:virt_text [["●" :GruvboxBlue]]}}}})
  (load_snippets))

{: config}
