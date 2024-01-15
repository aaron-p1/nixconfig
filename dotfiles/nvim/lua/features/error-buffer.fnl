(local {:api {: nvim_create_buf : nvim_buf_set_name : nvim_buf_set_lines}} vim)

(local old-traceback debug.traceback)
(local separator ["" "----------------------------------------" ""])

(var error-buffer nil)

(lambda create-error-buffer []
  (let [bufnr (nvim_create_buf true true)]
    (nvim_buf_set_name bufnr "Lua errors")
    bufnr))

(lambda log-errors? [trace]
  (not (string.match trace "lua/lsp_signature/helper.lua:341")))

(fn new-traceback [...]
  (let [trace (old-traceback ...)]
    (if (and error-buffer (log-errors? trace))
        (let [lines (vim.split trace "\n")]
          (vim.schedule (fn []
                          (nvim_buf_set_lines error-buffer -1 -1 false
                                              separator)
                          (nvim_buf_set_lines error-buffer -1 -1 false lines)))
          "")
        trace)))

(fn setup []
  (set error-buffer (create-error-buffer))
  (set debug.traceback new-traceback))

{: setup}
