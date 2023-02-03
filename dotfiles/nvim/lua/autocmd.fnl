(local {:api {: nvim_buf_line_count
              : nvim_buf_get_offset
              : nvim_create_augroup
              : nvim_create_autocmd}
        :highlight {:on_yank h-on-yank}} vim)

(local {: set_options} (require :helper))
(local {: get-profile-config} (require :profiles))

;; 512K
(local huge-file-size (* 1024 512))

(lambda fix-huge-file [{:buf bufnr}]
  (let [line-count (nvim_buf_line_count bufnr)
        buffer-size (nvim_buf_get_offset bufnr line-count)]
    (if (> buffer-size huge-file-size)
        (do
          (vim.opt.eventignore:append :FileType)
          (set vim.wo.wrap false)
          (set vim.bo.swapfile false)
          (set vim.bo.undolevels -1))
        (vim.opt.eventignore:remove :FileType))))

(fn setup []
  (get-profile-config :autocmds)
  ;; disable numbers in terminal mode
  (let [augroup (nvim_create_augroup :Terminal {:clear true})]
    (nvim_create_autocmd :TermOpen
                         {:group augroup
                          :callback #(set_options vim.opt_local
                                                  {:number false
                                                   :relativenumber false
                                                   :cursorline false
                                                   :spell false})}))
  ;; highlight on yank
  (let [augroup (nvim_create_augroup :YankHighlight {:clear true})]
    (nvim_create_autocmd :TextYankPost
                         {:group augroup :callback #(h-on-yank {:timeout 300})}))
  ;; delete hidden scp files
  (let [augroup (nvim_create_augroup :HiddenScp {:clear true})]
    (nvim_create_autocmd :BufRead
                         {:group augroup
                          :pattern "scp://*"
                          :callback #(set_options vim.bo {:bufhidden :delete})}))
  ;; huge files fix
  (let [augroup (nvim_create_augroup :FixHugeFiles {:clear true})]
    (nvim_create_autocmd :BufRead {:group augroup :callback fix-huge-file})))

{: setup}
