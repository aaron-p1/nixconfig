(local {: setup} (require :nvim-surround))

(fn config []
  (setup {:highlight {:duration 0} :move_cursor false :indent_lines false}))

{: config}
