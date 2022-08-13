(local {: map_keys : register_plugin_wk} (require :helper))

(lambda get-keymaps [bufnr gs ga]
  [; Navigation
   [:n
    "[c"
    #(if (= nil vim.o.diff) "<Cmd>Gitsigns prev_hunk<CR>" "[c")
    {:desc "Prev hunk"}]
   ; ]]
   ; [[
   [:n
    "]c"
    #(if (= nil vim.o.diff) "<Cmd>Gitsigns prev_hunk<CR>" "]c")
    {:desc "Next hunk"}]
   ; Staging
   [:n :<Leader>ghs gs.stage_hunk {:desc :Stage}]
   [:v
    :<Leader>ghs
    #(gs.stage_hunk [(vim.fn.line ".") (vim.fn.line :v)])
    {:desc :Stage}]
   [:n :<Leader>ghu gs.undo_stage_hunk {:desc "Undo stage"}]
   ; Reset hunk
   [:n :<Leader>ghr gs.reset_hunk {:desc :Reset}]
   [:v
    :<Leader>ghr
    #(gs.reset_hunk [(vim.fn.line ".") (vim.fn.line :v)])
    {:desc :Reset}]
   [:n :<Leader>ghR gs.reset_buffer {:desc "Reset buffer"}]
   ; View
   [:n :<Leader>ghp gs.preview_hunk {:desc :Preview}]
   [:n :<Leader>ghl #(gs.blame_line {:full true}) {:desc :Line}]
   ; Selection
   [[:o :x] :ih ga.select_hunk {:desc "In hunk"}]])

(fn config []
  (local gs (require :gitsigns))
  (local ga (require :gitsigns.actions))
  (gs.setup {:update_debounce 300
             :on_attach (fn [bufnr]
                          (map_keys get-keymaps bufnr gs ga)
                          (register_plugin_wk {:prefix :<Leader>
                                               :buffer bufnr
                                               :map {:g {:name :Git
                                                         :h {:name :Hunk}
                                                         :b {:name :Blame}}}}))}))

{: config}
