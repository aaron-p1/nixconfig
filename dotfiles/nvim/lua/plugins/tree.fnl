(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(fn config []
  (local nt (require :nvim-tree))
  (nt.setup {:disable_netrw false :hijack_netrw false})
  (kset :n :<Leader>bb nt.toggle {:desc :Toggle})
  (kset :n :<Leader>bf #(nt.find_file true) {:desc "Find file"})
  (kset :n :<Leader>b< #(nt.resize -20) {:desc "Resize -20"})
  (kset :n :<Leader>b> #(nt.resize 20) {:desc "Resize +20"})
  (register_plugin_wk {:prefix :<Leader> :map {:b {:name "Nvim tree"}}}))

{: config}
