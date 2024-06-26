(local {: expand : getcwd} vim.fn)

(local {: map_keys} (require :helper))
(local {:register wk-register} (require :plugins.which-key))

(local {:on_attach general-on-attach :getCapabilities get-capabilities}
       (require :plugins.lspconfig))

(local jdtls (require :jdtls))
(local jsetup (require :jdtls.setup))

(fn get-keymaps [bufnr]
  [[:n :<Leader>llo jdtls.organize_imports {:desc "Organize imports"}]
   [:n :<Leader>llv jdtls.extract_variable {:desc "Extract variable"}]
   [:v
    :<Leader>llv
    (fn []
      (jdtls.extract_variable true))
    {:desc "Extract variable"}]
   [:n :<Leader>llc jdtls.extract_constant {:desc "Extract constant"}]
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

; TODO debugging support
(fn on-attach [client bufnr]
  (general-on-attach client bufnr)
  (jsetup.add_commands)
  (map_keys get-keymaps bufnr)
  (wk-register {:buffer bufnr :prefix :<Leader> :map {:l {:l {:name :Java}}}}))

(let [config {:cmd [:jdtls
                    :-data
                    (.. (expand "~/.cache/jdtls") (getcwd))]
              :root_dir (jsetup.find_root [:.git :mvnw :gradlew])
              :capabilities (get-capabilities)
              :extended_client_capabilities jdtls.extendedClientCapabilities
              :on_attach on-attach}]
  (pcall jdtls.start_or_attach config))
