(local {:fn {: line} :api {: nvim_buf_get_name}} vim)

(local {: map_keys} (require :helper))
(local {:register wk-register} (require :plugins.which-key))

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

(lambda disable-gitsigns [bufnr]
  (let [file-path (nvim_buf_get_name bufnr)]
    (string.match file-path :secrets)))

(lambda attach [bufnr]
  (map_keys get-keymaps bufnr)
  (wk-register {:buffer bufnr
                :prefix :<Leader>
                :map {:g {:name :Git :h {:name :Hunk} :b {:name :Blame}}}}))

(lambda on-attach [bufnr]
  (if (disable-gitsigns bufnr) false (attach bufnr)))

(fn config []
  (setup {:update_debounce 300 :diff_opts {:linematch 60} :on_attach on-attach}))

{: config}
