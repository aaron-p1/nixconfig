(local {:api {: nvim_create_augroup : nvim_create_autocmd}} vim)

(local disabled-filetypes [:gitcommit])

(fn config []
  (set vim.g.EditorConfig_exclude_patterns ["fugitive://.*" "scp://.*"])
  (let [group (nvim_create_augroup :EditorConfigIgnore {})]
    (nvim_create_autocmd :FileType
                         {:pattern disabled-filetypes
                          :callback #(set vim.b.EditorConfig_disable 1)})))

{: config}
