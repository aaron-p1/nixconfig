(local {:api {: nvim_buf_delete
              : nvim_buf_line_count
              : nvim_buf_get_offset
              : nvim_chan_send
              : nvim_create_augroup
              : nvim_create_autocmd}
        :cmd {: edit}
        :fn {: substitute}
        :highlight {:on_yank h-on-yank}
        :keymap {:set kset}} vim)

(local {: set_options} (require :helper))
(local {: get-profile-config} (require :profiles))

(local huge-file-size (* 1024 512))

(lambda remove-pid-from-term-title [title]
  "term://dir//pid:cmd -> term://dir//cmd"
  (substitute title "term://.\\{-}//\\zs\\d*:" "" ""))

(lambda send-to-terminal [input]
  (let [job-id vim.b.terminal_job_id]
    (if job-id (nvim_chan_send job-id input))))

(lambda on-term-open [{:buf bufnr}]
  (set_options vim.opt_local {:number false
                              :relativenumber false
                              :cursorline false
                              :spell false})
  (kset :n :cd #(send-to-terminal "\004") {:buffer bufnr :desc "Send <C-d>"})
  (kset :n :cc #(send-to-terminal "\003") {:buffer bufnr :desc "Send <C-c>"}))

(lambda on-term-close [{: file :buf bufnr}]
  (let [new-cmd (remove-pid-from-term-title file)]
    (kset :n :r (fn []
                  (edit new-cmd)
                  (nvim_buf_delete bufnr {:force true}))
          {:buffer bufnr})
    (kset :n :q #(nvim_buf_delete bufnr {:force true}) {:buffer bufnr})))

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
    (nvim_create_autocmd :TermOpen {:group augroup :callback on-term-open})
    (nvim_create_autocmd :TermClose {:group augroup :callback on-term-close}))
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
