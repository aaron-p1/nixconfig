(local {:set kset} vim.keymap)

(local {: setup : pounce} (require :pounce))

(fn config []
  (setup {:accept_keys :ABCDEFGHIJKLMNOPQRSTUVWXYZ})
  (kset :n :<Leader>p pounce {:desc "Jump to line"}))

{: config}
