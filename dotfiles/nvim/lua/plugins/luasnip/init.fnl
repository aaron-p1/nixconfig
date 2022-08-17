(local {: startswith} vim)

(local {:set kset} vim.keymap)

(local {: register_plugin_wk : replace_tc} (require :helper))

(fn config []
  (local ls (require :luasnip))
  (local {:choiceNode tcn :insertNode tin} (require :luasnip.util.types))
  (local sn (require :plugins.luasnip.snippets))
  (kset :n :<Leader>rpl
        (fn []
          (tset package.loaded :plugins.luasnip nil)
          (each [p _ (pairs package.loaded)]
            (when (startswith p :plugins.luasnip.)
              (tset package.loaded p nil)))) {:desc :Luasnip})
  (kset :i :<C-K> ls.expand {:desc :Expand})
  (kset [:i :s] :<C-J> #(ls.jump -1) {:desc :Prev})
  (kset [:i :s] :<C-L> #(ls.jump 1) {:desc :Next})
  (kset :n :<Leader>i ls.unlink_current {:desc "Unlink snip"})
  (kset [:i :s] :<C-E> #(if (ls.choice_active)
                            (replace_tc :<Plug>luasnip-next-choice)
                            (replace_tc :<C-E>))
        {:expr true :remap true :desc "Next choice"})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:r {:name :Reload :p {:name :Plugin}}}})
  (ls.config.set_config {:updateevents "TextChanged,TextChangedI"
                         :region_check_events :InsertEnter
                         :ext_opts {tcn {:active {:virt_text [["●"
                                                               :GruvboxOrange]]}}
                                    tin {:active {:virt_text [["●"
                                                               :GruvboxBlue]]}}}})
  (sn.load_snippets))

{: config}
