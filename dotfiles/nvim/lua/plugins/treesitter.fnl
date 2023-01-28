(local {: nvim_buf_get_lines} vim.api)

(local {: any} (require :helper))

(local {: setup} (require :nvim-treesitter.configs))

(fn config []
  (setup {:ensure_installed :all
          :highlight {:enable true
                      :disable (fn [lang bufnr]
                                 (let [lines (nvim_buf_get_lines bufnr 0 -1
                                                                 false)]
                                   (any lines #(< vim.o.synmaxcol (length $1)))))}
          :indent {:enable true}
          :autotag {:enable true :filetypes [:html :xml :blade :vue]}}))

{: config}
