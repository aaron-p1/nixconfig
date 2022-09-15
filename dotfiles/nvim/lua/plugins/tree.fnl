(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(local {: setup : toggle : find_file : resize} (require :nvim-tree))

(fn config []
  (setup {:disable_netrw false :hijack_netrw false})
  (kset :n :<Leader>bb toggle {:desc :Toggle})
  (kset :n :<Leader>bf #(find_file true) {:desc "Find file"})
  (kset :n :<Leader>b< #(resize :-20) {:desc "Resize -20"})
  (kset :n :<Leader>b> #(resize :+20) {:desc "Resize +20"})
  (register_plugin_wk {:prefix :<Leader> :map {:b {:name "Nvim tree"}}}))

{: config}
