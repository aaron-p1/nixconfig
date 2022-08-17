(local ns (require :nvim-surround))

(fn config []
  (ns.setup {:highlight {:duration 0} :move_cursor false :indent_lines false}))

{: config}
