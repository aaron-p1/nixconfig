(local {: register_plugin_wk} (require :helper))

(local {: setup} (require :which-key))

(fn config []
  (setup {:disable {:filetypes [:TelescopePrompt :DressingInput]}})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:t {:name :Tab}
                             :d {:name :Diff}
                             :c {:name :Compare}
                             :v {:name "Virtual comments" :d {:name :Delete}}}}))

{: config}
