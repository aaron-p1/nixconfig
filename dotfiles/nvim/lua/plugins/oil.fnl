(local {:api {: nvim_replace_termcodes : nvim_feedkeys}} vim)

(local {: setup :select oil-select} (require :oil))

(fn select-tab []
  (oil-select {:horizontal true})
  (let [key (nvim_replace_termcodes :<C-w>T true false true)]
    (nvim_feedkeys key :n true)))

(fn config []
  (setup {:columns [:icon :permissions :size]
          :view_options {:show_hidden true}
          :keymaps {:<C-t> select-tab}
          :silence_scp_warning true}))

{: config}
