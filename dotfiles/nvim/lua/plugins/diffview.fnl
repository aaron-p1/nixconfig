(local {:api {: nvim_buf_get_mark} :keymap {:set kset}} vim)

(local {:register wk-register} (require :plugins.which-key))

(local {: file_history : setup} (require :diffview))
(local {: select_next_entry
        : select_prev_entry
        : focus_entry
        : listing_style
        : refresh_files
        : select_entry
        : options
        : open_commit_log
        : goto_file_tab
        : copy_hash
        : close} (require :diffview.actions))

(fn _G.diffview_file_history []
  (let [[start-line] (nvim_buf_get_mark 0 "[")
        [end-line] (nvim_buf_get_mark 0 "]")]
    (file_history [start-line end-line])))

(fn config []
  (setup {:file_panel {:win_config {:position :right}}
          :keymaps {:disable_defaults true
                    :view {:<Tab> select_next_entry :<S-Tab> select_prev_entry}
                    :file_panel {:<CR> focus_entry
                                 :<Tab> select_next_entry
                                 :<S-Tab> select_prev_entry
                                 :i listing_style
                                 :R refresh_files}
                    :file_history_panel {:<CR> select_entry
                                         :g! options
                                         :L open_commit_log
                                         :<Tab> select_next_entry
                                         :<S-Tab> select_prev_entry
                                         :gf goto_file_tab
                                         :gy copy_hash}
                    :option_panel {:<Tab> select_entry :q close}}
          :hooks {:diff_buf_read #(set vim.opt_local.wrap false)}})
  (kset :n :<Leader>gdf "<Cmd>DiffviewFileHistory %<CR>"
        {:silent true :desc "Current file history"})
  (kset [:n :v] :<Leader>gdF :<Cmd>DiffviewFileHistory<CR>
        {:silent true :desc "All file history"})
  (kset :n :<Leader>gdr
        "<Cmd>set operatorfunc=v:lua.diffview_file_history<CR>g@"
        {:silent true :desc "Ranged file history"})
  (kset :n :<Leader>gdcf #(file_history nil [:--range=ORIG_HEAD..FETCH_HEAD])
        {:silent true :desc :Fetched})
  (kset :n :<Leader>gdch #(file_history nil [:--range=ORIG_HEAD..HEAD])
        {:silent true :desc :Head})
  (wk-register {:prefix :<Leader>
                :map {:g {:name :Git :d {:name :Diffview :c {:name :Commits}}}}}))

{: config}
