(local {: register_plugin_wk} (require :helper))

(local {: setup_ts_grammar : setup} (require :orgmode))
(local {:setup ts-setup} (require :nvim-treesitter.configs))

(fn config []
  (setup_ts_grammar)
  (ts-setup {:highlight {:additional_vim_regex_highlighting [:org]}
             :ensure_installed [:org]})
  (setup {:mappings {:prefix :<Leader>O}
          :org_agenda_files ["~/Documents/private/orgmode/*"]})
  (register_plugin_wk {:prefix :<Leader> :map {:O {:name :Orgmode}}}))

{: config}
