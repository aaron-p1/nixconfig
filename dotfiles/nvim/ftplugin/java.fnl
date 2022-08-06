; TODO convert to kebab-case
(local {:registerPluginWk register-plugin-wk} (require :helper))

(local {:on_attach general-on-attach :getCapabilities get-capabilities}
       (require :plugins.lspconfig))

(local jdtls (require :jdtls))
(local jsetup (require :jdtls.setup))

(local additional-keymaps
       [[:n :<Leader>llo jdtls.organize_imports {:desc "Organize imports"}]
        [:n :<Leader>llv jdtls.organize_variable {:desc "Extract variable"}]
        [:v
         :<Leader>llv
         (fn []
           (jdtls.extract_variable true))
         {:desc "Extract variable"}]
        [:n :<Leader>llc jdtls.organize_constant {:desc "Extract constant"}]
        [:v
         :<Leader>llc
         (fn []
           (jdtls.extract_constant true))
         {:desc "Extract constant"}]
        [:v
         :<Leader>llm
         (fn []
           (jdtls.extract_method true))
         {:desc "Extract method"}]])

(fn map-keys [bufnr]
  (each [_ map (ipairs additional-keymaps)]
    (vim.keymap.set (. map 1) (. map 2) (. map 3)
                    (vim.fn.extend (. map 4) {:buffer bufnr}))))

; TODO debugging support
(fn on-attach [client bufnr]
  (general-on-attach client bufnr)
  (jsetup.add_commands)
  (map-keys bufnr)
  (register-plugin-wk {:prefix :<Leader>
                       :buffer bufnr
                       :map {:l {:l {:name :Java}}}}))

(let [config {:cmd [:jdt-language-server]
              :root_dir (jsetup.find_root [:.git :mvnw :gradlew])
              :capabilities (get-capabilities)
              :extended_client_capabilities jdtls.extendedClientCapabilities
              :on_attach on-attach}]
  (jdtls.start_or_attach config))
