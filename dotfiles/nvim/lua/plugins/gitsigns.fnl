(local {: line} vim.fn)

(local {: map_keys : register_plugin_wk} (require :helper))

(local {: stage_hunk
        : undo_stage_hunk
        : reset_hunk
        : reset_buffer
        : preview_hunk
        : blame_line
        : setup} (require :gitsigns))
(local {: select_hunk} (require :gitsigns.actions))

(lambda get-keymaps [bufnr]
  [; Navigation
   [:n
    "[c"
    #(if vim.o.diff "[c" "<Cmd>Gitsigns prev_hunk<CR>")
    {:expr true :desc "Prev hunk"}]
   [:n
    "]c"
    #(if vim.o.diff "]c" "<Cmd>Gitsigns next_hunk<CR>")
    {:expr true :desc "Next hunk"}]
   ; Staging
   [:n :<Leader>ghs stage_hunk {:desc :Stage}]
   [:v :<Leader>ghs #(stage_hunk [(line ".") (line :v)]) {:desc :Stage}]
   [:n :<Leader>ghu undo_stage_hunk {:desc "Undo stage"}]
   ; Reset hunk
   [:n :<Leader>ghr reset_hunk {:desc :Reset}]
   [:v :<Leader>ghr #(reset_hunk [(line ".") (line :v)]) {:desc :Reset}]
   [:n :<Leader>ghR reset_buffer {:desc "Reset buffer"}]
   ; View
   [:n :<Leader>ghp preview_hunk {:desc :Preview}]
   [:n :<Leader>ghl #(blame_line {:full true}) {:desc :Line}]
   ; Selection
   [[:o :x] :ih select_hunk {:desc "In hunk"}]])

(fn config []
  (setup {:update_debounce 300
          :on_attach (fn [bufnr]
                       (map_keys get-keymaps bufnr)
                       (register_plugin_wk {:prefix :<Leader>
                                            :buffer bufnr
                                            :map {:g {:name :Git
                                                      :h {:name :Hunk}
                                                      :b {:name :Blame}}}}))}))

{: config}
