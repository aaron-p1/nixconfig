(local {: startswith} vim)

(local {: nvim_buf_get_lines
        : nvim_buf_set_lines
        : nvim_create_augroup
        : nvim_create_autocmd} vim.api)

(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(var old-msg [])

(fn save-commit-msg [{:buf bufnr}]
  (let [lines (nvim_buf_get_lines bufnr 0 -1 true)
        msg-lines (icollect [_ line (ipairs lines) :until (startswith line "#")]
                    line)]
    (set old-msg msg-lines)))

(fn put-commit-msg []
  (if (< 0 (length old-msg)) (nvim_buf_set_lines 0 0 1 true old-msg)))

(fn add-keymap []
  (let [[first-arg] vim.g.fugitive_result.args
        [first-line] old-msg
        msg-start (if first-line (first-line:sub 1 10))]
    (when (and (= :commit first-arg) msg-start)
      (kset :n :<Leader>gc put-commit-msg
            {:buffer true :desc (.. "Paste " msg-start)}))))

(fn config []
  (kset :n :<Leader>gbb "<Cmd>Git blame<CR>" {:silent true :desc "Whole file"})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:g {:name :Git :b {:name :Blame}}}})
  (let [group (nvim_create_augroup :FugitiveCommitMsg {:clear true})]
    (nvim_create_autocmd :User
                         {: group
                          :pattern :FugitiveEditor
                          :callback add-keymap})
    (nvim_create_autocmd :BufWrite
                         {: group
                          :pattern :COMMIT_EDITMSG
                          :callback save-commit-msg})))

{: config}
