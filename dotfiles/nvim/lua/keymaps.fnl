(local {:api {: nvim_buf_set_text
              : nvim_tabpage_get_number
              : nvim_list_tabpages
              : nvim_get_current_tabpage}
        :cmd {: tabclose : tabprevious : split}
        :fn {: getreg}
        :keymap {:set kset}} vim)

(local {: get-operator-range
        :open-term {:hor open-term-h :ver open-term-v :tab open-term-t}
        : add-term-keymaps} (require :helper))

(local {: get-profile-config} (require :profiles))
(local {:register wk-register} (require :plugins.which-key))

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
  ;; clear line
  (kset :n :dD :0D {:desc "Clear line"})
  ;; alt + Esc for leaving terminal
  (kset :t :<A-Esc> "<C-\\><C-N>")
  ;; diff maps
  (kset :n :<Leader>du :<Cmd>diffupdate<CR> {:silent true})
  (kset :n :<Leader>dt :<Cmd>diffthis<CR> {:silent true})
  ;; noh
  (kset :n :<Leader>n :<Cmd>nohlsearch<CR> {:silent true})
  ;; tab maps
  (kset :n :<C-w><C-t> "<Cmd>tab split<CR>"
        {:silent true :desc "Open in new tab"})
  (kset :n :<Leader>tc close-tab {:desc "Tab close"})
  (kset :n :<Leader>to :<Cmd>tabonly<CR> {:silent true})
  ;; term
  (add-term-keymaps :<Leader>ctt vim.o.shell)
  (add-term-keymaps :<Leader>cts (.. "~//" vim.o.shell))
  ;; replace text object
  (kset :n :gp "<Cmd>set operatorfunc=v:lua.replace_selection<CR>g@"
        {:silent true})
  (wk-register {:prefix :<Leader>
                :map {:d {:name :Diff}
                      :t {:name :Tab}
                      :c {:name "Create buffer"
                          :t {:name :Terminal
                              :t {:name "Shell here"}
                              :s {:name "Shell home"}}}}}))

{: setup}
