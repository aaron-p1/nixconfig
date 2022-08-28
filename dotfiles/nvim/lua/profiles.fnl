(local currentProfile vim.env.NVIM_PROFILE)

(local p {})

(local config {:webt-game {:lsp-settings p.webt-lsp-settings}})

(lambda get-profile-config [config-name ...]
  (let [conf-fn (?. config currentProfile config-name)]
    (if conf-fn (conf-fn ...))))

;;;; Configuration functions

;;; webt

(lambda p.webt-lsp-config [server]
  (match server
    :jsonls (let [schema-path :./web/assets/json/json-schemas/]
              {:settings {:schemas [{:uri (.. schema-path :config.schema.json)
                                     :fileMatch [:json/default-config.json]}]}})
    _ {}))

{: get-profile-config}
