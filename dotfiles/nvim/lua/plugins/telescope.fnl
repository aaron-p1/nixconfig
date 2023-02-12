(local {:set kset} vim.keymap)

(local {: register_plugin_wk} (require :helper))

(local {: setup : load_extension} (require :telescope))
(local {: open_with_trouble} (require :trouble.providers.telescope))
(local {: resume
        : find_files
        : live_grep
        : grep_string
        : buffers
        : marks
        : current_buffer_fuzzy_find
        : filetypes
        : help_tags
        : lsp_references
        : lsp_document_symbols
        : lsp_implementations
        : lsp_definitions
        : git_commits
        : git_bcommits
        : git_stash
        : symbols} (require :telescope.builtin))

(fn config []
  (setup {:defaults {:mappings {:i {:<Leader>ot open_with_trouble}
                                :n {:<Leader>ot open_with_trouble}}
                     :preview {:filesize_limit 1}}
          :extensions {:fzf {:fuzzy true
                             :override_generic_sorter true
                             :override_file_sorter true
                             :case_mode :smart_case}}})
  (load_extension :fzf)
  (load_extension :luasnip)
  (kset :n :<C-S-T> resume {:desc "Resume last search"})
  ;; DEPENDENCIES: fd
  (kset :n :<Leader>fa
        #(find_files {:find_command [:fd
                                     :--type=file
                                     :--size=-1M
                                     :--hidden
                                     :--strip-cwd-prefix
                                     :--no-ignore]}) {:desc "All files"})
  ;; DEPENDENCIES: fd
  (kset :n :<Leader>ff
        #(find_files {:find_command [:fd
                                     :--type=file
                                     :--size=-1M
                                     :--hidden
                                     :--strip-cwd-prefix
                                     :--exclude=.git]}) {:desc :Files})
  ;; DEPENDENCIES: ripgrep
  (kset :n :<Leader>fr live_grep {:desc "Live grep"})
  ;; DEPENDENCIES: ripgrep
  (kset :n :<Leader>ft #(grep_string {:additional_args #[:--hidden]})
        {:desc "Grep string"})
  ;; vim
  (kset :n :<Leader>fb buffers {:desc :Buffers})
  (kset :n :<Leader>fm marks {:desc :Marks})
  (kset :n :<Leader>fcr current_buffer_fuzzy_find {:desc "Fuzzy find"})
  (kset :n :<Leader>fy filetypes {:desc "Set filetype"})
  (kset :n :<Leader>fh help_tags {:desc "Help tags"})
  ;; lsp
  (kset :n :<Leader>flr lsp_references {:desc :References})
  (kset :n :<Leader>fls lsp_document_symbols {:desc "Document symbols"})
  (kset :n :<Leader>fli lsp_implementations {:desc :Implementations})
  (kset :n :<Leader>fld lsp_definitions {:desc :Definitions})
  ;; git
  (kset :n :<Leader>fgc git_commits {:desc :Commits})
  (kset :n :<Leader>fgb git_bcommits {:desc :BCommits})
  (kset :n :<Leader>fgt git_stash {:desc :Stash})
  ;; symbols
  (kset :n :<Leader>fs symbols {:desc :Symbols})
  (register_plugin_wk {:prefix :<Leader>
                       :map {:f {:name :Telescope
                                 :c {:name "Current buffer"}
                                 :l {:name :Lsp}
                                 :g {:name :Git}}}}))

{: config}
