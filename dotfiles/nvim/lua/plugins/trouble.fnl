(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(fn config []
  (local t (require :trouble))
  (t.setup {:mode :loclist})
  (kset :n :<Leader>oo #(t.toggle :document_diagnostics)
        {:desc "Document diagnostics"})
  (kset :n :<Leader>oi #(t.toggle :lsp_implementations)
        {:desc :Implementations})
  (kset :n :<Leader>or #(t.toggle :lsp_references) {:desc :References})
  (register_plugin_wk {:prefix :<Leader> :map {:o {:name :Trouble}}}))

{: config}
