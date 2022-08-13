(fn config []
  (local p (require :pounce))
  (p.setup {:accept_keys :ABCDEFGHIJKLMNOPQRSTUVWXYZ})
  (vim.keymap.set :n :<Leader>p p.pounce {:desc "Jump to line"}))

{: config}
