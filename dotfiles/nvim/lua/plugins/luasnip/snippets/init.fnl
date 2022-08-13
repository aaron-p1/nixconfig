(local {: tbl_extend : tbl_map : endswith} vim)

(local {: extend : stdpath : readdir : fnamemodify} vim.fn)

(local {: flatten} (require :helper))
(local {: add_snippets} (require :luasnip))

(local snippet-dir :lua/plugins/luasnip/snippets)
(local snippet-module-prefix :plugins.luasnip.snippets)

(local group-assignments
       {:all [:all]
        :json [:json]
        :php [:php :c_like :laravel]
        :blade [:blade :html]
        :html [:html :javascript :c_like]
        :javascript [:javascript :c_like]
        :typescript [:typescript :c_like]
        :vue [:html :javascript :c_like]})

(lambda get-snippet-files [subdir]
  (let [path (.. (stdpath :config) "/" snippet-dir "/" subdir)]
    (readdir path #(if (endswith $1 :.lua) 1 0))))

(fn get-snippets-from-directory [subdir]
  (collect [_ file (ipairs (get-snippet-files subdir))]
    (let [module-name (fnamemodify file ":r")]
      (values module-name (require (.. snippet-module-prefix "." subdir "."
                                       module-name))))))

(fn load-common []
  (let [snippet-groups (get-snippets-from-directory :common)
        ga group-assignments
        assignments (tbl_extend :keep ga {:typescriptreact ga.typescript})
        snippets (collect [ft groups (pairs assignments)]
                   ft
                   (flatten (tbl_map #(. snippet-groups $1) groups)))]
    (add_snippets nil snippets {:key :common})))

(fn load-file-templates []
  (let [snippets (get-snippets-from-directory :file-templates)]
    (add_snippets nil snippets {:key :file-templates})))

(fn load-snippets []
  (load-common)
  (load-file-templates))

{:load_snippets load-snippets}
