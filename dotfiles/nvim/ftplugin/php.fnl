(local {: nvim_create_autocmd : nvim_buf_get_lines : nvim_buf_set_text} vim.api)

(local {: set_options : replace-when-diag} (require :helper))

(set_options vim.bo {:suffixesadd :.php})

(nvim_create_autocmd :BufWrite
                     {:buffer 0
                      :callback #(replace-when-diag $1.buf "Expected ';'%.$"
                                                    "([^;])$" "%1;")})
