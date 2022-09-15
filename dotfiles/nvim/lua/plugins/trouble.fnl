(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(local {: setup : toggle} (require :trouble))

(fn config []
  (setup {:mode :loclist})
  (kset :n :<Leader>oo #(toggle :document_diagnostics)
        {:desc "Document diagnostics"})
  (kset :n :<Leader>oi #(toggle :lsp_implementations) {:desc :Implementations})
  (kset :n :<Leader>or #(toggle :lsp_references) {:desc :References})
  (register_plugin_wk {:prefix :<Leader> :map {:o {:name :Trouble}}}))

{: config}
