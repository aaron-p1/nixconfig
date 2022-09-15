(local {:api {: nvim_get_runtime_file} :fn {: readfile}} vim)

(local domain-file-path :extra/secrets/gitlab-domains.txt)

;; fnlfmt: skip
(fn read-domains []
  (match-try (nvim_get_runtime_file domain-file-path false)
             [file] (pcall readfile file)
             (true content) content
             (catch _ [])))

(fn config []
  (set vim.g.fugitive_gitlab_domains (read-domains)))

{: config}
