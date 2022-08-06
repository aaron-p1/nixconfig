(local {:setOptions set-options} (require :helper))

(local {: nvim_create_augroup : nvim_create_autocmd} vim.api)

(fn setup []
  ;; disable numbers in terminal mode
  (let [augroup (nvim_create_augroup :Terminal {:clear true})]
    (nvim_create_autocmd :TermOpen
                         {:group augroup
                          :callback #(set-options vim.o
                                                  {:number false
                                                   :relativenumber false})}))
  ;; highlight on yank
  (let [augroup (nvim_create_augroup :YankHighlight {:clear true})]
    (nvim_create_autocmd :TextYankPost
                         {:group augroup
                          :callback #(vim.highlight.on_yank {:timeout 300})}))
  ;; delete hidden scp files
  (let [augroup (nvim_create_augroup :HiddenScp {:clear true})]
    (nvim_create_autocmd :BufRead
                         {:group augroup
                          :pattern "scp://*"
                          :callback #(set-options vim.bo {:bufhidden :delete})})))

{: setup}
