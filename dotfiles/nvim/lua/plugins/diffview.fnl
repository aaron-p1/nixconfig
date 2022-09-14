(local {: nvim_buf_get_mark} vim.api)

(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(local dv (require :diffview))
(local da (require :diffview.actions))

(fn _G.diffview_file_history []
  (let [[start-line] (nvim_buf_get_mark 0 "[")
        [end-line] (nvim_buf_get_mark 0 "]")]
    (dv.file_history [start-line end-line])))

(fn config []
  (dv.setup {:file_panel {:win_config {:position :right}}
             :keymaps {:disable_defaults true
                       :view {:<Tab> da.select_next_entry
                              :<S-Tab> da.select_prev_entry}
                       :file_panel {:<CR> da.focus_entry
                                    :<Tab> da.select_next_entry
                                    :<S-Tab> da.select_prev_entry
                                    :i da.listing_style
                                    :R da.refresh_files}
                       :file_history_panel {:<CR> da.select_entry
                                            :g! da.options
                                            :L da.open_commit_log
                                            :<Tab> da.select_next_entry
                                            :<S-Tab> da.select_prev_entry
                                            :gf da.goto_file_tab
                                            :gy da.copy_hash}
                       :option_panel {:<Tab> da.select_entry :q da.close}}
             :hooks {:diff_buf_read #(set vim.opt_local.wrap false)}})
  (kset :n :<Leader>gdf "<Cmd>DiffviewFileHistory %<CR>"
        {:silent true :desc "Current file history"})
  (kset [:n :v] :<Leader>gdF :<Cmd>DiffviewFileHistory<CR>
        {:silent true :desc "All file history"})
  (kset :n :<Leader>gdr
        "<Cmd>set operatorfunc=v:lua.diffview_file_history<CR>g@"
        {:silent true :desc "Ranged file history"})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:g {:name :Git :d {:name :Diffview}}}}))

{: config}
