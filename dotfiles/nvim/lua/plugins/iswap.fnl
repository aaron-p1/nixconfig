(local {: register_plugin_wk} (require :helper))

(fn config []
  (local i (require :iswap))
  (i.setup {:keys :abcdefghijklmnopqrstuvwxyz :grey :disable :autoswap true})
  (vim.keymap.set :n :<Leader>ss i.iswap_with {:desc :ISwap})
  (register_plugin_wk {:prefix :<Leader> :map {:s {:name :Swap}}}))

{: config}
