(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(local {: setup : iswap_with} (require :iswap))

(fn config []
  (setup {:keys :abcdefghijklmnopqrstuvwxyz :grey :disable :autoswap true})
  (kset :n :<Leader>ss iswap_with {:desc :ISwap})
  (register_plugin_wk {:prefix :<Leader> :map {:s {:name :Swap}}}))

{: config}
