(var setup-run? false)
(var to-register [])

(lambda really-register [config]
  (let [{:register wk-register} (require :which-key)]
    (wk-register config.map {:prefix (or config.prefix "")
                             :buffer config.buffer})))

(lambda register [config]
  (if setup-run?
      (really-register config)
      (table.insert to-register config)))

(fn config []
  (let [{: setup} (require :which-key)]
    (setup {:disable {:filetypes [:TelescopePrompt :DressingInput]}}))
  (set setup-run? true)
  (each [_ config (ipairs to-register)]
    (really-register config))
  (set to-register []))

{: config : register}
