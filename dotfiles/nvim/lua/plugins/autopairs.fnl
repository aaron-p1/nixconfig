(local {: setup} (require :nvim-autopairs))
(local {: on_confirm_done} (require :nvim-autopairs.completion.cmp))
(local {: event} (require :cmp))

(fn config []
  (setup {:disable_filetype [:TelescopePrompt :dap-repl :dapui_watches]})
  (event:on :confirm_done
            (on_confirm_done {; map <CR> on insert mode
                              :map_cr false
                              ; it will auto insert `()` after select function or method item
                              :map_complete true
                              ; automatically select the first item
                              :auto_select true})))

{: config}
