(local {: split
        :api {: nvim_create_augroup : nvim_create_autocmd}
        :fn {: getcwd}} vim)

(local {: map : concat : contains :is_empty is-empty} (require :helper))

(local profile-string (or vim.env.NVIM_PROFILES ""))
(local profiles (split profile-string "," {:plain true :trimempty true}))

(local existing-profiles [:webt-game :cmake])

(local config (map existing-profiles #(values $1 {})))

(local merge-lists [[] #(concat $1 $2)])

(local config-merge-fn {:autocmd [nil #$] :json-schemas merge-lists})

(lambda has-profile [profile]
  (contains profiles profile))

(lambda execute-profile-config [profile-name config-name ?default ...]
  (let [conf-fn (?. config profile-name config-name)]
    (if conf-fn (conf-fn ...) ?default)))

(lambda merge-results [config-name result-list]
  (let [[init-val merge-fn] (or (. config-merge-fn config-name) [])]
    (if (= nil merge-fn) (. result-list 1)
        (accumulate [result init-val _ val (ipairs result-list)]
          (merge-fn result val)))))

(lambda get-profile-config [config-name ?default ...]
  (let [additional-args [...]
        result-list (map profiles
                         #(execute-profile-config $1 config-name ?default
                                                  (unpack additional-args)))]
    (if (is-empty result-list) ?default (merge-results config-name result-list))))

(lambda run-profile-config [config-name ...]
  (let [additional-args [...]]
    (each [_ profile (ipairs profiles)]
      (execute-profile-config profile config-name nil (unpack additional-args)))))

;;;; Configuration functions

;;; webt

(fn config.webt-game.autocmd []
  (let [augroup (nvim_create_augroup :WebtGotoFile {:clear true})]
    (nvim_create_autocmd :FileType
                         {:group augroup
                          :pattern :json
                          :callback #(set vim.bo.includeexpr "'web/' . v:fname")})))

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
      :fileMatch [:textures/**/*.json]}]))

{: profiles : has-profile : get-profile-config : run-profile-config}
