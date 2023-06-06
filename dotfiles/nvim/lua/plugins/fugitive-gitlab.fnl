(local {:api {: nvim_get_runtime_file}
        :fn {: readfile}
        :json {:decode json-decode}
        : tbl_map
        : tbl_values} vim)

(local domain-file-path :extra/secrets/gitlab-domains.json)

;; fnlfmt: skip
(fn read-domain-config []
  (match-try (nvim_get_runtime_file domain-file-path false)
             [file] (pcall readfile file)
             (true content) (pcall json-decode (table.concat content))
             (true domain-config) domain-config
             (catch _ {})))

(fn config []
  (let [domain-config (read-domain-config)
        domains (->> (tbl_values domain-config)
                     (tbl_map #(?. $ :domain)))
        tokens (tbl_map #(?. $ :token) domain-config)]
    (set vim.g.fugitive_gitlab_domains domains)
    (set vim.g.gitlab_api_keys tokens)))

{: config}
