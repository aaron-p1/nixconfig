(local {: tbl_deep_extend
        : split
        :api {: nvim_buf_get_option
              : nvim_buf_set_option
              : nvim_command
              : nvim_create_augroup
              : nvim_clear_autocmds
              : nvim_create_autocmd
              : nvim_get_runtime_file}
        :lsp {:buf {: format
                    : declaration
                    : type_definition
                    : hover
                    : signature_help
                    : list_workspace_folders
                    : add_workspace_folder
                    : remove_workspace_folder
                    : code_action
                    : range_code_action
                    : rename
                    : document_highlight
                    : clear_references}
              :protocol {: make_client_capabilities}
              :codelens {:run codelens-run}}
        :diagnostic {:goto_prev d-prev
                     :goto_next d-next
                     :open_float d-float
                     :enable d-enable
                     :disable d-disable}} vim)

(local {: map_keys : concat} (require :helper))
(local {: get-profile-config} (require :profiles))
(local {:register wk-register} (require :plugins.which-key))

(local nvim-lsp (require :lspconfig))

(local {:json {:schemas json-schemas}} (require :schemastore))

(local servers [; c
                {:server :cmake}
                {:server :clangd
                 :cmd [:env
                       (.. :CPATH= (or vim.env.NVIM_CLANGD_INCLUDE ""))
                       :clangd]}
                ; dart
                {:server :dartls}
                ; html
                {:server :html :filetypes [:html :blade]}
                ; css
                {:server :cssls}
                {:server :tailwindcss}
                ; php
                {:server :intelephense}
                ; json
                {:server :jsonls
                 :settings {:json {:validate {:enable true}
                                   :schemas (concat (json-schemas)
                                                    (get-profile-config :json-schemas
                                                                        []))}}}
                ; yaml
                {:server :yamlls}
                ; vue
                {:server :volar :init_options {:typescript {:tsdk "@tsLib@"}}}
                ; haskell
                {:server :hls}
                ; nix
                {:server :rnix}
                ; elixir
                ; {:server :elixirls :cmd [:elixir-ls]}
                ; python
                {:server :pyright}
                ; javascript
                {:server :tsserver}
                ; R
                {:server :r_language_server}])

(local formatting-preferences {:nix :null-ls :html :null-ls :json :null-ls})

(lambda format-buffer [bufnr ?async]
  (let [async (if (= nil ?async) true ?async)
        ft (nvim_buf_get_option bufnr :filetype)]
    (format {: async :name (?. formatting-preferences ft)})))

(lambda get-keymaps [bufnr tb]
  [; jump to
   [:n :gd #(tb.lsp_definitions {:jump_type :never}) {:desc :Definition}]
   [:n :gD declaration {:desc :Declaration}]
   [:n :gi tb.lsp_implementations {:desc :Implementations}]
   [:n :gr tb.lsp_references {:desc :References}]
   [:n :<Leader>lD type_definition {:desc "Type definition"}]
   [:n "[d" d-prev {:desc "Prev diagnostic"}]
   ; ][
   [:n "]d" d-next {:desc "Next diagnostic"}]
   [:n :<Leader>ld d-float {:desc "Show diagnostic"}]
   [:n :<Leader>ltd #(d-enable bufnr) {:desc "Enable diagnostics"}]
   [:n :<Leader>ltD #(d-disable bufnr) {:desc "Disable diagnostics"}]
   ; show info
   [:n :K hover {:desc :Hover}]
   [:n :<C-K> signature_help {:desc :Signature}]
   [:n
    :<Leader>lwl
    #(print (vim.inspect (list_workspace_folders)))
    {:desc :List}]
   [:n :<Leader>lwa add_workspace_folder {:desc "Add folder"}]
   [:n :<Leader>lwr remove_workspace_folder {:desc "Remove folder"}]
   ; edit
   [:n :<Leader>lf #(format-buffer bufnr) {:desc "Format async"}]
   [:n :<Leader>lF #(format-buffer bufnr false) {:desc "Format sync"}]
   ; bufnr
   [:n :<Leader>lc code_action {:desc "Code action"}]
   [:n :<Leader>lr rename {:desc :Rename}]
   [:n :<Leader>ll codelens-run {:desc :Codelens}]])

(lambda add-highlighting [bufnr]
  (let [group (nvim_create_augroup :lsp_document_highlight {:clear false})]
    (nvim_clear_autocmds {:buffer bufnr : group})
    (nvim_create_autocmd :CursorHold
                         {:buffer bufnr
                          : group
                          :callback document_highlight
                          :desc "Document highlight"})
    (nvim_create_autocmd :CursorMoved
                         {:buffer bufnr
                          : group
                          :callback clear_references
                          :desc "Clear all the references"})))

(lambda on-attach [client bufnr]
  (local tb (require :telescope.builtin))
  (local ls (require :lsp_signature))
  (when (not (= (?. vim.bo bufnr :filetype) :elixir))
    (ls.on_attach {:bind true :hint_prefix "→ "}))
  (map_keys get-keymaps bufnr tb)
  (when (and (not= :null-ls client.name)
             client.server_capabilities.documentHighlightProvider)
    (add-highlighting bufnr))
  (wk-register {:buffer bufnr
                :prefix :<Leader>
                :map {:l {:name :LSP :w {:name :Workspace} :t {:name :Toggle}}}}))

(fn get-capabilities []
  (local cnl (require :cmp_nvim_lsp))
  (tbl_deep_extend :force (cnl.default_capabilities)
                   {:offsetEncoding [:utf-16]}))

(lambda configure-servers [capabilities]
  (each [_ lspdef (ipairs servers)]
    (let [default-options {:on_attach on-attach : capabilities}]
      (match lspdef
        {:server server-name &as options} (let [server (. nvim-lsp server-name)
                                                p-conf (get-profile-config :lsp-config
                                                                           {}
                                                                           server-name)
                                                config (tbl_deep_extend :force
                                                                        default-options
                                                                        options
                                                                        p-conf)]
                                            (server.setup config))
        {&as options} (print "Error in lspconfig: " (vim.inspect options))
        server-name (let [server-config (. nvim-lsp server-name)]
                      (server-config.setup default-options))))))

(lambda configure-lua [capabilities]
  (let [runtime-path (split package.path ";")
        lsp-settings {:Lua {:runtime {:version :LuaJIT :path runtime-path}
                            :diagnostics {:globals [:vim]}
                            :workspace {:library (nvim_get_runtime_file "" true)}
                            :telemetry {:enable false}}}]
    (table.insert runtime-path :lua/?.lua)
    (table.insert runtime-path :lua/?/init.lua)
    (nvim-lsp.lua_ls.setup {:on_attach on-attach
                            : capabilities
                            :settings lsp-settings})))

(fn config []
  (let [capabilities (get-capabilities)]
    (configure-servers capabilities)
    (configure-lua capabilities)))

{:on_attach on-attach :getCapabilities get-capabilities : config}
