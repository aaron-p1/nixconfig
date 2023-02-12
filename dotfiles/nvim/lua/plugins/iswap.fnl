(local {:set kset} vim.keymap)

(local {:register wk-register} (require :plugins.which-key))

(local {: setup : iswap_with} (require :iswap))

(fn config []
  (setup {:keys :abcdefghijklmnopqrstuvwxyz :grey :disable :autoswap true})
  (kset :n :<Leader>ss iswap_with {:desc :ISwap})
  (wk-register {:prefix :<Leader> :map {:s {:name :Swap}}}))

{: config}
