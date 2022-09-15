(local {: setup
        :methods {:DIAGNOSTICS_ON_SAVE d-on-save}
        :builtins {:diagnostics d :formatting f :code_actions c :hover h}}
       (require :null-ls))

(local {:on_attach lsp-attach :getCapabilities lsp-capabilities}
       (require :plugins.lspconfig))

(fn config []
  (setup {:sources [; editorconfig
                    ; DEPENDENCIES: editorconfig-checker
                    (d.editorconfig_checker.with {:command :editorconfig-checker
                                                  :method d-on-save})
                    ; text / markdown
                    h.dictionary
                    ; web languages
                    f.prettier
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
                    ; DEPENDENCIES: nixfmt
                    f.nixfmt
                    ; DEPENDENCIES: statix
                    c.statix
                    ; elixir
                    d.credo
                    f.surface
                    ; python
                    d.flake8
                    f.autopep8]
          :on_attach lsp-attach
          :capabilities (lsp-capabilities)}))

{: config}
