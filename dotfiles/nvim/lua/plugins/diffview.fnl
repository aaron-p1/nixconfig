(fn config []
  (local dv (require :diffview))
  (local da (require :diffview.actions))
  (dv.setup {:file_panel {:win_config {:position :right}}
             :keymaps {:disable_defaults true
                       :view {:<Tab> da.select_next_entry
                              :<S-Tab> da.select_prev_entry}
                       :file_panel {:<CR> da.focus_entry
                                    :<Tab> da.select_next_entry
                                    :<S-Tab> da.select_prev_entry
                                    :i da.listing_style
                                    :R da.refresh_files}}
             :hooks {:diff_buf_read #(set vim.opt_local.wrap false)}}))

{: config}
