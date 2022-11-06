(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(local {: live_grep} (require :telescope.builtin))

(local {: setup : toggle : find_file : resize} (require :nvim-tree))

(fn live-grep-in-dir [node]
  (let [abs-path (if (= node.type :directory) node.absolute_path
                     node.parent node.parent.absolute_path)]
    (when abs-path
      (live_grep {:cwd abs-path}))))

(fn config []
  (setup {:disable_netrw false
          :hijack_netrw false
          :view {:mappings {:list [{:key :<Leader>fr
                                    :action "Live grep"
                                    :action_cb live-grep-in-dir}]}}})
  (kset :n :<Leader>bb toggle {:desc :Toggle})
  (kset :n :<Leader>bf #(find_file true) {:desc "Find file"})
  (kset :n :<Leader>b< #(resize :-20) {:desc "Resize -20"})
  (kset :n :<Leader>b> #(resize :+20) {:desc "Resize +20"})
  (register_plugin_wk {:prefix :<Leader> :map {:b {:name "Nvim tree"}}}))

{: config}
