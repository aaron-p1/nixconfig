(local {:keymap {:set kset}} vim)

(local {: extensions} (require :telescope))

(local {: setup} (require :virt-notes))

(fn config []
  (setup)
  (kset :n :<Leader>fv extensions.virt_notes.virt_notes {:desc "Virt notes"}))

{: config}
