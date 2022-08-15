(local {: nvim_replace_termcodes
        : nvim_win_get_cursor
        : nvim_buf_get_lines
        : nvim_buf_set_lines} vim.api)

(fn config []
  (set vim.g.copilot_no_tab_map true)
  (set vim.g.copilot_assume_mapped true)
  (let [map :<C-o>
        termcode (nvim_replace_termcodes :<C-o> true false true)]
    (vim.keymap.set :i map
                    #(string.gsub ((. vim.fn "copilot#Accept") termcode)
                                  "copilot#TextQueuedForInsertion%(%)"
                                  "v:lua.copilot_get_text()")
                    {:noremap true
                     :silent true
                     :expr true
                     :replace_keycodes false}))

  (fn _G.copilot_get_text []
    "Get copilot text and delete line after if duplcate"
    (let [result ((. vim.fn "copilot#TextQueuedForInsertion"))
          [_ & result-lines] (vim.split result "\n" {:trimempty true})
          last-result (. result-lines (length result-lines))
          ;; row is 1 indexed
          [row col] (nvim_win_get_cursor 0)
          [line-after] (nvim_buf_get_lines 0 row (+ row 1) false)]
      (when (= line-after last-result)
        (nvim_buf_set_lines 0 row (+ row 1) false {}))
      result)))

{: config}
