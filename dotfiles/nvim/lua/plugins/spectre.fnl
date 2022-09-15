(local {:set kset} vim.keymap)

(local {: setup : open} (require :spectre))

(fn config []
  (setup {:open_cmd :tabnew})
  (kset :n :<Leader>S open))

{: config}
