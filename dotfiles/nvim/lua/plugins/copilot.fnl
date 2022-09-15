(local {: split
        :api {: nvim_replace_termcodes
              : nvim_win_get_cursor
              : nvim_buf_get_lines
              : nvim_buf_set_lines
              : nvim_create_augroup
              : nvim_create_autocmd}
        :fn {: copilot#TextQueuedForInsertion : copilot#Accept}
        :keymap {:set kset}} vim)

(var line-text [])

(fn _G.copilot_get_text [line?]
  "Get copilot text and delete line after if duplicate"
  (let [result (copilot#TextQueuedForInsertion)
        [first-result & result-lines] (split result "\n")
        last-result (. result-lines (length result-lines)) ;; row is 1 indexed
        [row col] (nvim_win_get_cursor 0)
        [line-after] (nvim_buf_get_lines 0 row (+ row 1) false)]
    (when (= line-after last-result)
      (nvim_buf_set_lines 0 row (+ row 1) false {}))
    (set line-text (if line? result-lines []))
    (if line? first-result result)))

(fn _G.copilot_get_next_line []
  (let [[line & other] line-text]
    (set line-text other)
    (if line line "")))

(lambda accept-custom [termcode line?]
  (let [next-line-expr "<CR><C-U><C-R><C-O>=v:lua.copilot_get_next_line()<CR>"
        fn-replacement (.. "v:lua.copilot_get_text(v:" (if line? :true :false)
                           ")")]
    (if (and line? (not= 0 (length line-text)))
        (nvim_replace_termcodes next-line-expr true true true)
        (string.gsub (copilot#Accept termcode)
                     "copilot#TextQueuedForInsertion%(%)" fn-replacement))))

(fn config []
  (set vim.g.copilot_no_tab_map true)
  (set vim.g.copilot_assume_mapped true)
  (let [map :<C-o>
        line-map :<A-o>
        termcode (nvim_replace_termcodes map true false true)
        line-termcode (nvim_replace_termcodes line-map true false true)
        opts {:noremap true :silent true :expr true :replace_keycodes false}]
    (kset :i map #(accept-custom termcode false) opts)
    (kset :i line-map #(accept-custom termcode true) opts))
  (let [group (nvim_create_augroup :CopilotSuggestionReset {:clear true})]
    (nvim_create_autocmd :InsertLeave {: group :callback #(set line-text [])})))

{: config}
