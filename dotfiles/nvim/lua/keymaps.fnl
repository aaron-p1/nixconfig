(local {:api {: nvim_buf_set_text
              : nvim_tabpage_get_number
              : nvim_list_tabpages
              : nvim_get_current_tabpage}
        :cmd {: tabclose : tabprevious : split}
        :fn {: getreg}
        :keymap {:set kset}} vim)

(local {: get-operator-range
        :open-term {:hor open-term-h :ver open-term-v :tab open-term-t}}
       (require :helper))

(local {: get-profile-config} (require :profiles))

(fn _G.replace_selection [motion-type]
  (let [[start-row start-col end-row end-col] (get-operator-range motion-type)
        register-content (getreg :0 1 true)]
    (nvim_buf_set_text 0 start-row start-col end-row end-col register-content)))

(fn close-tab []
  (let [count (if (= vim.v.count 0) 1 vim.v.count)
        go-prev? (<= (+ count (nvim_tabpage_get_number 0))
                     (length (nvim_list_tabpages)))]
    (pcall #(for [_ 1 count 1]
              (tabclose)))
    (when (and go-prev? (< 1 (nvim_tabpage_get_number 0)))
      (tabprevious))))

(fn setup []
  (get-profile-config :keymaps)
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
  ;; term
  (kset :n :<Leader>ctx #(open-term-h vim.o.shell) {:desc "Term horizontal"})
  (kset :n :<Leader>ctv #(open-term-v vim.o.shell) {:desc "Term vertical"})
  (kset :n :<Leader>ctt #(open-term-t vim.o.shell) {:desc "Term tab"})
  ;; replace text object
  (kset :n :gp "<Cmd>set operatorfunc=v:lua.replace_selection<CR>g@"
        {:silent true}))

{: setup}
