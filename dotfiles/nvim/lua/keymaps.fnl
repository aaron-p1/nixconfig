(local {: nvim_tabpage_get_number : nvim_list_tabpages} vim.api)

(local {:set kset} vim.keymap)

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
  (kset :n :<Leader>to :<Cmd>tabonly<CR> {:silent true}))

{: setup}
