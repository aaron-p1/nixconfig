(local {: nvim_create_autocmd} vim.api)

(nvim_create_autocmd [:BufRead :BufNewFile]
                     {:pattern :**/queries/*/*.scm
                      :command "setfiletype query"})
