(local {: register_plugin_wk} (require :helper))

(fn config []
  (vim.keymap.set :n :<Leader>gbb "<Cmd>Git blame<CR>"
                  {:silent true :desc "Whole file"})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:g {:name :Git :b {:name :Blame}}}}))

{: config}
