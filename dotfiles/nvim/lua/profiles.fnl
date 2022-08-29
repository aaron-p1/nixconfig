(local {: getcwd} vim.fn)

(local {: map} (require :helper))

(local profile vim.env.NVIM_PROFILE)

(local existing-profiles [:webt-game])

(local config (map existing-profiles #(values $1 {})))

(lambda get-profile-config [config-name ?default ...]
  (let [conf-fn (?. config profile config-name)]
    (if conf-fn (conf-fn ...) ?default)))

;;;; Configuration functions

;;; webt

(fn config.webt-game.json-schemas []
  (let [cwd (getcwd)
        schema-path (.. cwd :/web/assets/json/json-schemas/)]
    [{:url (.. schema-path :config.schema.json)
      :fileMatch [:default-config.json]}
     {:url (.. schema-path :keymap-presets.schema.json)
      :fileMatch [:keymap-presets.json]}
     {:url (.. schema-path :level-list.schema.json)
      :fileMatch [:available-levels.json]}
     {:url (.. schema-path :level.schema.json) :fileMatch [:levels/*.json]}
     {:url (.. schema-path :textures.schema.json)
      :fileMatch [:textures/**.json]}]))

{: get-profile-config}
