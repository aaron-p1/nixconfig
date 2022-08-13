(local {: nvim_get_runtime_file} vim.api)

(local domain-file-path :extra/secrets/gitlab-domains.txt)

(fn read-domains []
  (match-try (nvim_get_runtime_file domain-file-path false) [file]
             (pcall vim.fn.readfile file) (true content) content (catch _ [])))

(fn config []
  (set vim.g.fugitive_gitlab_domains (read-domains)))

{: config}
