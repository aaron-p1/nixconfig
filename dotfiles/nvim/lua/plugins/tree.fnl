(local {:api {: nvim_buf_get_name
              : nvim_get_current_line
              : nvim_create_augroup
              : nvim_create_autocmd}
        :cmd {: normal}
        :fn {: filereadable}
        :keymap {:set kset}} vim)

(local {: concat} (require :helper))

(local {:register wk-register} (require :plugins.which-key))

(local {: live_grep : find_files} (require :telescope.builtin))
(local {:close t-close} (require :telescope.actions))
(local {: get_selected_entry} (require :telescope.actions.state))

(local {: setup : resize} (require :nvim-tree))
(local {:config {:mappings {: default_on_attach}}
        :tree {: get_node_under_cursor : open : find_file : toggle}}
       (require :nvim-tree.api))

(local {: expand_or_collapse} (require :nvim-tree.lib))
(local {:fn open-file} (require :nvim-tree.actions.node.open-file))

(lambda get-telescope-path [?cwd]
  (let [entry (get_selected_entry)
        file-name entry.filename
        file-path (if ?cwd
                      (.. ?cwd "/" file-name)
                      file-name)]
    (values file-path [entry.lnum entry.col])))

(lambda open-telescope-selected [?cwd action prompt-bufnr]
  (let [(file-path [line col]) (get-telescope-path ?cwd)]
    (t-close prompt-bufnr)
    (open-file action file-path)
    (when (and line col)
      (normal {1 (.. line :G col :|zz) :bang true}))))

(lambda attach-live-grep-mappings [cwd _ map]
  (map {:n :i} :<CR> (partial open-telescope-selected cwd :edit))
  (map {:n :i} :<C-x> (partial open-telescope-selected cwd :split))
  (map {:n :i} :<C-v> (partial open-telescope-selected cwd :vsplit))
  true)

(lambda live-grep-in-dir []
  (let [node (get_node_under_cursor)
        abs-path (if (= node.type :directory) node.absolute_path
                     node.parent node.parent.absolute_path)]
    (when abs-path
      (live_grep {:cwd abs-path
                  :attach_mappings (partial attach-live-grep-mappings abs-path)}))))

(lambda attach-find-dir-mappings [_ map]
  (map {:n :i} :<CR>
       (fn [prompt-bufnr]
         (t-close prompt-bufnr)
         (find_file (get-telescope-path))
         (normal {1 :zz :bang true})
         (let [node (get_node_under_cursor)]
           (if (not node.open) (expand_or_collapse node)))))
  (map {:n :i} :<C-x> (partial open-telescope-selected nil :split))
  (map {:n :i} :<C-v> (partial open-telescope-selected nil :vsplit))
  true)

(lambda find-directory []
  ;; DEPENDENCIES: fd
  (let [{:config explorer-config} (require :nvim-tree.explorer.filters)
        show-git-ignored? (not explorer-config.filter_git_ignored)
        show-hidden? (not explorer-config.filter_dotfiles)
        find-command [:fd
                      :--type=directory
                      :--strip-cwd-prefix
                      :--exclude=.git
                      (if show-hidden? :--hidden)
                      (if show-git-ignored? :--no-ignore)]]
    (find_files {:find_command find-command
                 :attach_mappings attach-find-dir-mappings})))

(lambda always-open [action]
  (let [node (get_node_under_cursor)]
    (open-file action node.absolute_path)))

(fn open-and-find-fugitive []
  (let [line (nvim_get_current_line)
        ?fname (string.match line "^. (.+)$")]
    (when ?fname
      (open)
      (find_file ?fname))))

(fn on-attach [buffer]
  (lambda set-map [key cb desc]
    (kset :n key cb {:desc (.. "nvim-tree: " desc) : buffer}))
  (default_on_attach buffer)
  (set-map :O #(always-open :edit) "Edit file and dir")
  (set-map :<C-x> #(always-open :split) "Split file and dir")
  (set-map :<C-v> #(always-open :vsplit) "Vsplit file and dir")
  (set-map :<C-t> #(always-open :tabnew) "tabnew file and dir")
  (set-map :<Leader>ff find-directory "Find directories")
  (set-map :<Leader>fr live-grep-in-dir "Live grep"))

(fn config []
  (setup {:disable_netrw false
          :hijack_netrw false
          :on_attach on-attach
          :git {:enable false}})
  (kset :n :<Leader>bb #(toggle) {:desc :Toggle})
  (kset :n :<Leader>bf #(open {:find_file true}) {:desc "Find file"})
  (kset :n :<Leader>b< #(resize :-20) {:desc "Resize -20"})
  (kset :n :<Leader>b> #(resize :+20) {:desc "Resize +20"})
  (let [group (nvim_create_augroup :FugitiveNvimTree {})]
    (nvim_create_autocmd :FileType
                         {: group
                          :pattern :fugitive
                          :callback (fn [{:buf bufnr}]
                                      (kset :n :<Leader>bf
                                            open-and-find-fugitive
                                            {:buffer bufnr :desc "Find file"}))}))
  (wk-register {:prefix :<Leader> :map {:b {:name "Nvim tree"}}}))

{: config}
