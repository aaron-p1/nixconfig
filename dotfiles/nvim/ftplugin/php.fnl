(local {: nvim_create_autocmd : nvim_buf_get_lines : nvim_buf_set_text} vim.api)

(local {: set_options} (require :helper))
(local {: show-types} (require :features.lsp-show-type))

(var buf-show-types {})
(var types-waiting {})
(var buf-changed {})

(set_options vim.bo {:suffixesadd :.php})

(lambda show-type-if-changed [bufnr]
  (tset types-waiting bufnr false)
  (when (and (?. buf-changed bufnr) (?. buf-show-types bufnr))
    (show-types bufnr :php)
    (tset buf-changed bufnr false)
    (tset types-waiting bufnr true)
    (vim.defer_fn #(show-type-if-changed bufnr) 1000)))

(nvim_create_autocmd :LspAttach
                     {:buffer 0
                      :callback (fn [{:buf bufnr :data {:client_id id}}]
                                  (let [client (vim.lsp.get_client_by_id id)]
                                    (when (= :intelephense client.name)
                                      (tset buf-show-types bufnr true)
                                      (show-types bufnr :php))))})

(nvim_create_autocmd :LspDetach
                     {:buffer 0
                      :callback (fn [{:buf bufnr}]
                                  (tset buf-show-types bufnr false))})

(nvim_create_autocmd [:TextChanged :InsertLeave]
                     {:buffer 0
                      :callback (fn [{:buf bufnr}]
                                  (when (?. buf-show-types bufnr)
                                    (tset buf-changed bufnr true)
                                    (if (not (?. types-waiting bufnr))
                                        (show-type-if-changed bufnr))))})
