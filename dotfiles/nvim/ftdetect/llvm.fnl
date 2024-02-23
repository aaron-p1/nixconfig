(local {:api {: nvim_create_autocmd} : bo :cmd {: setfiletype}} vim)

(nvim_create_autocmd [:BufRead :BufNewFile]
                     {:pattern "*.ll"
                      :callback #(setfiletype :llvm)})
