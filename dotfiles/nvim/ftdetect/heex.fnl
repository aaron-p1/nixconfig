(local {: nvim_create_autocmd} vim.api)

(nvim_create_autocmd [:BufRead :BufNewFile]
                     {:pattern :*.heex :command "setfiletype heex"})
