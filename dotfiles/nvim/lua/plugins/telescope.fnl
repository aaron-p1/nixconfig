(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(fn config []
  (local t (require :telescope))
  (local trouble (require :trouble.providers.telescope))
  (local tt (require :telescope.themes))
  (local tb (require :telescope.builtin))
  (t.setup {:defaults {:mappings {:i {:<Leader>ot trouble.open_with_trouble}
                                  :n {:<Leader>ot trouble.open_with_trouble}}
                       :preview {:filesize_limit 1}}
            :extensions {:fzf {:fuzzy true
                               :override_generic_sorter true
                               :override_file_sorter true
                               :case_mode :smart_case}}})
  (t.load_extension :fzf)
  ;; DEPENDENCIES: fd
  (kset :n :<Leader>fa
        #(tb.find_files {:find_command [:fd
                                        :--type=file
                                        :--size=-1M
                                        :--hidden
                                        :--strip-cwd-prefix
                                        :--no-ignore]})
        {:desc "All files"})
  ;; DEPENDENCIES: fd
  (kset :n :<Leader>ff
        #(tb.find_files {:find_command [:fd
                                        :--type=file
                                        :--size=-1M
                                        :--hidden
                                        :--strip-cwd-prefix
                                        :--exclude=.git]})
        {:desc :Files})
  ;; DEPENDENCIES: ripgrep
  (kset :n :<Leader>fr tb.live_grep {:desc "Live grep"})
  ;; DEPENDENCIES: ripgrep
  (kset :n :<Leader>ft #(tb.grep_string {:additional_args #[:--hidden]})
        {:desc "Grep string"})
  ;; vim
  (kset :n :<Leader>fb tb.buffers {:desc :Buffers})
  (kset :n :<Leader>fm tb.marks {:desc :Marks})
  (kset :n :<Leader>fcr tb.current_buffer_fuzzy_find {:desc "Fuzzy find"})
  ;; lsp
  (kset :n :<Leader>flr tb.lsp_references {:desc :References})
  (kset :n :<Leader>fls tb.lsp_document_symbols {:desc "Document symbols"})
  (kset :n :<Leader>fli tb.lsp_implementations {:desc :Implementations})
  (kset :n :<Leader>fld tb.lsp_definitions {:desc :Definitions})
  ;; git
  (kset :n :<Leader>fgc tb.git_commits {:desc :Commits})
  (kset :n :<Leader>fgb tb.git_bcommits {:desc :BCommits})
  (kset :n :<Leader>fgt tb.git_stash {:desc :Stash})
  ;; symbols
  (kset :n :<Leader>fs tb.symbols {:desc :Symbols})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:f {:name :Telescope
                                 :c {:name "Current buffer"}
                                 :l {:name :Lsp}
                                 :g {:name :Git}}}}))

{: config}
