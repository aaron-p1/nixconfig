(local {: split :keymap {:set kset}} vim)

(local {: map : concat : contains :is_empty is-empty : add-term-keymaps}
       (require :helper))

(local {:register wk-register} (require :plugins.which-key))

(local profile-string (or vim.env.NVIM_PROFILES ""))
(local profiles (split profile-string "," {:plain true :trimempty true}))
;; profiles that do something

(local existing-profiles [:nixconfig
                          :cmake
                          :podman-compose
                          :laravel
                          :sail
                          :tenancy-for-laravel
                          :npm])

(local config (map existing-profiles #(values $1 {})))

(local no-merge [nil #$])
(local merge-lists [[] #(concat $1 $2)])

(local config-merge-fn {:startup no-merge
                        :autocmds no-merge
                        :keymaps no-merge
                        :json-schemas merge-lists})

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

;;;; Utility functions

(lambda get-compose-cmd [env-infix ?cmd]
  (let [env-prefix :NVIM_PROFILE_
        env-suffixes {:options :_CONTAINER_OPTIONS :container :_CONTAINER}
        container-options-env (.. env-prefix env-infix env-suffixes.options)
        container-env (.. env-prefix env-infix env-suffixes.container)
        container-options (or (. vim.env container-options-env) "")
        container (or (. vim.env container-env) "")]
    (.. "podman-compose exec " container-options " " container " " (or ?cmd ""))))

;;;; Configuration functions

;;; Available functions for configuration
;; vim
;; - startup
;; - autocmds
;; - keymaps
;; lspconfig
;; - lsp-config
;; - json-schemas

;;; nixconfig

(fn config.nixconfig.keymaps []
  (add-term-keymaps :<Leader>cps "sudo make switch")
  (add-term-keymaps :<Leader>cpb "sudo make boot")
  (wk-register {:prefix :<Leader>c
                :map {:p {:name :Profile
                          :s {:name "Switch config"}
                          :b {:name "Boot config"}}}}))

;;; cmake

(set config.cmake (require :profiles.cmake))
;;; laravel

;; ENV:
;; - NVIM_PROFILE_SHELL_CONTAINER
;; - NVIM_PROFILE_SHELL_CONTAINER_OPTIONS
;; - NVIM_PROFILE_TINKER_CONTAINER
;; - NVIM_PROFILE_TINKER_CONTAINER_OPTIONS

(fn config.laravel.keymaps []
  (let [sail? (has-profile :sail)
        podman-compose? (has-profile :podman-compose)
        php-tinker-cmd "php artisan tinker"
        tinker-cmd (if sail? "sail tinker"
                       podman-compose? (get-compose-cmd :PHP php-tinker-cmd)
                       php-tinker-cmd)]
    (add-term-keymaps :<Leader>cpt tinker-cmd)
    (wk-register {:prefix :<Leader>c
                  :map {:p {:name :Profile :t {:name :Tinker}}}})
    (when (or sail? podman-compose?)
      (let [shell-cmd (if sail? "sail shell" (get-compose-cmd :PHP :bash))]
        (add-term-keymaps :<Leader>cps shell-cmd)
        (wk-register {:prefix :<Leader>cp :map {:s {:name :Shell}}})))
    (when (has-profile :tenancy-for-laravel)
      (let [tinker-tenant-artisan-cmd " artisan tenants:run tinker"
            php-tinker-tenant-cmd (.. :php tinker-tenant-artisan-cmd)
            tinker-tenant-cmd (if sail? (.. :sail tinker-tenant-artisan-cmd)
                                  podman-compose?
                                  (get-compose-cmd :PHP php-tinker-tenant-cmd)
                                  php-tinker-tenant-cmd)]
        (add-term-keymaps :<Leader>cpT tinker-tenant-cmd)
        (wk-register {:prefix :<Leader>cp :map {:T {:name "Tenant tinker"}}})))
    (when (has-profile :npm)
      (let [watch-cmd "npm run watch"
            prod-cmd "npm run prod"]
        (if sail?
            (do
              (add-term-keymaps :<Leader>cpw (.. "sail " watch-cmd))
              (add-term-keymaps :<Leader>cpp (.. "sail " prod-cmd)))
            podman-compose?
            (do
              (add-term-keymaps :<Leader>cpw (get-compose-cmd :PHP watch-cmd))
              (add-term-keymaps :<Leader>cpp (get-compose-cmd :PHP prod-cmd)))
            (do
              (add-term-keymaps :<Leader>cpw watch-cmd)
              (add-term-keymaps :<Leader>cpp prod-cmd)))
        (wk-register {:prefix :<Leader>cp
                      :map {:w {:name "Npm watch"} :p {:name "Npm prod"}}})))))

{: profiles : has-profile : get-profile-config : run-profile-config}
