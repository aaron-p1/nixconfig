(local {:api {: nvim_buf_get_name} :fn {: filereadable} :keymap {:set kset}}
       vim)

(local {: register_plugin_wk} (require :helper))

(local {: live_grep} (require :telescope.builtin))

(local {: setup : resize} (require :nvim-tree))
(local {:tree {: open : find_file : toggle}} (require :nvim-tree.api))
(local {:fn open-file} (require :nvim-tree.actions.node.open-file))

(lambda live-grep-in-dir [node]
  (let [abs-path (if (= node.type :directory) node.absolute_path
                     node.parent node.parent.absolute_path)]
    (when abs-path
      (live_grep {:cwd abs-path}))))

(lambda always-open [action node]
  (open-file action node.absolute_path))

(fn open-and-find-file []
  (let [fname (nvim_buf_get_name 0)]
    (when (and fname (= 1 (filereadable fname)))
      (open)
      (find_file fname))))

(fn config []
  (setup {:disable_netrw false
          :hijack_netrw false
          :view {:mappings {:list [{:key :O
                                    :action "Edit file and dir"
                                    :action_cb (partial always-open :edit)}
                                   {:key :<C-x>
                                    :action "Split file and dir"
                                    :action_cb (partial always-open :split)}
                                   {:key :<C-v>
                                    :action "Vsplit file and dir"
                                    :action_cb (partial always-open :vsplit)}
                                   {:key :<C-t>
                                    :action "tabnew file and dir"
                                    :action_cb (partial always-open :tabnew)}
                                   {:key :<Leader>fr
                                    :action "Live grep"
                                    :action_cb live-grep-in-dir}]}}})
  (kset :n :<Leader>bb #(toggle) {:desc :Toggle})
  (kset :n :<Leader>bf open-and-find-file {:desc "Find file"})
  (kset :n :<Leader>b< #(resize :-20) {:desc "Resize -20"})
  (kset :n :<Leader>b> #(resize :+20) {:desc "Resize +20"})
  (register_plugin_wk {:prefix :<Leader> :map {:b {:name "Nvim tree"}}}))

{: config}
