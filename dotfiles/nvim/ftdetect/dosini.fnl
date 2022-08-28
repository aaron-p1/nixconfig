(local {: nvim_create_autocmd} vim.api)

(nvim_create_autocmd [:BufRead :BufNewFile]
                     {:pattern ".env{,.example}"
                      :callback (fn []
                                  (vim.cmd "setfiletype dosini")
                                  (set vim.bo.commentstring "# %s"))})
