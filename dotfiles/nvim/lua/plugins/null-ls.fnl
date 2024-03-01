(local {:api {: nvim_buf_get_option}} vim)

(local {: all} (require :helper))

(local {: setup
        :methods {:DIAGNOSTICS_ON_SAVE d-on-save}
        :builtins {:diagnostics d :formatting f :code_actions c :hover h}}
       (require :null-ls))

(local {:on_attach lsp-attach :getCapabilities lsp-capabilities}
       (require :plugins.lspconfig))

(local disable-filetypes [:NvimTree])

(lambda should-attach [bufnr]
  (let [buf-ft (nvim_buf_get_option bufnr :filetype)]
    (all disable-filetypes #(not= buf-ft $))))

(fn config []
  (setup {:sources [; editorconfig
                    ; DEPENDENCIES: editorconfig-checker
                    (d.editorconfig_checker.with {:method d-on-save
                                                  :disabled_filetypes [:gitcommit]})
                    ; text / markdown
                    h.dictionary
                    ; web languages
                    f.prettier
                    ; php
                    ; DEPENDENCIES: php-cs-fixer
                    (f.phpcsfixer.with {:args [:--allow-risky=yes
                                               :--no-interaction
                                               :--quiet
                                               :fix
                                               :$FILENAME]})
                    ; shell
                    ; DEPENDENCIES: shellcheck
                    d.shellcheck
                    ; DEPENDENCIES: shellharden
                    f.shellharden
                    ; lua
                    ; DEPENDENCIES: stylua
                    f.stylua
                    ; fennel
                    ; DEPENDENCIES: fnlfmt
                    f.fnlfmt
                    ; nix
                    ; DEPENDENCIES: statix
                    d.statix
                    ; DEPENDENCIES: statix
                    c.statix
                    ; elixir
                    d.credo
                    ; python
                    d.flake8
                    f.autopep8]
          :should_attach should-attach
          :on_attach lsp-attach
          :capabilities (lsp-capabilities)}))

{: config}
