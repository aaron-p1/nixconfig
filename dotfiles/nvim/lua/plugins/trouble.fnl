(local {:set kset} vim.keymap)

(local {:register wk-register} (require :plugins.which-key))

(local {: setup : toggle} (require :trouble))

(fn config []
  (setup {:mode :loclist})
  (kset :n :<Leader>oo #(toggle :document_diagnostics)
        {:desc "Document diagnostics"})
  (kset :n :<Leader>oi #(toggle :lsp_implementations) {:desc :Implementations})
  (kset :n :<Leader>or #(toggle :lsp_references) {:desc :References})
  (wk-register {:prefix :<Leader> :map {:o {:name :Trouble}}}))

{: config}
