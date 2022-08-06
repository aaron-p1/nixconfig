(local {: nvim_create_augroup : nvim_create_autocmd} vim.api)

(fn exec []
  (let [augroup (nvim_create_augroup :filetypedetect {})
        ft-from-pattern (fn [ft pattern]
                          (nvim_create_autocmd [:BufRead :BufNewFile]
                                               {:group augroup
                                                : pattern
                                                :command (.. :setfiletype ft)}))]
    (ft-from-pattern :dosini ".env{,.example}")
    (ft-from-pattern :dockerfile :*.dockerfile)))

(when (not= 1 (vim.fn.exists :did_load_filetypes))
  (exec))
