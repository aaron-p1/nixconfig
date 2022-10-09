(local {: nvim_create_autocmd} vim.api)

(nvim_create_autocmd [:BufRead :BufNewFile]
                     {:pattern :*.g4 :command "setfiletype antlr4"})
