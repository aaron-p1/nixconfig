(local {: nvim_buf_get_mark
        : nvim_buf_get_lines
        : nvim_buf_set_text
        : nvim_tabpage_get_number
        : nvim_list_tabpages} vim.api)

(local {: getreg} vim.fn)

(local {:set kset} vim.keymap)

(fn _G.replace_selection [motion-type]
  (let [charwise? (= motion-type :char)
        [start-mark-row start-mark-col] (nvim_buf_get_mark 0 "[")
        [end-mark-row end-mark-col] (nvim_buf_get_mark 0 "]")
        start-row (- start-mark-row 1)
        end-row (- end-mark-row 1)
        [end-line] (nvim_buf_get_lines 0 end-row (+ end-row 1) false)
        end-line-length (length end-line)
        start-col (if charwise? start-mark-col 0)
        end-col (if charwise? (+ end-mark-col 1) end-line-length)
        register-content (getreg :0 1 true)]
    (nvim_buf_set_text 0 start-row start-col end-row end-col register-content)))

(fn close-tab []
  (let [count (if (= vim.v.count 0) 1 vim.v.count)
        go-prev? (<= (+ count (nvim_tabpage_get_number 0))
                     (length (nvim_list_tabpages)))]
    (pcall #(for [_ 1 count 1]
              (vim.cmd :tabclose)))
    (when (and go-prev? (< 1 (nvim_tabpage_get_number 0)))
      (vim.cmd :tabprevious))))

(fn setup []
  ;; alt + Esc for leaving terminal
  (kset :t :<A-Esc> "<C-\\><C-N>")
  ;; diff maps
  (kset :n :<Leader>du :<Cmd>diffupdate<CR> {:silent true})
  (kset :n :<Leader>dt :<Cmd>diffthis<CR> {:silent true})
  ;; noh
  (kset :n :<Leader>n :<Cmd>nohlsearch<CR> {:silent true})
  ;; tab maps
  (kset :n :<Leader>tc close-tab {:desc "Tab close"})
  (kset :n :<Leader>to :<Cmd>tabonly<CR> {:silent true})
  ;; replace text object
  (kset :n :gp "<Cmd>:set operatorfunc=v:lua.replace_selection<CR>g@"
        {:silent true}))

{: setup}
