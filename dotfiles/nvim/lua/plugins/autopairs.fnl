(fn config []
  (local ap (require :nvim-autopairs))
  (local ap_cmp (require :nvim-autopairs.completion.cmp))
  (local cmp (require :cmp))
  (ap.setup {:disable_filetype [:TelescopePrompt :dap-repl :dapui_watches]})
  (cmp.event:on :confirm_done
                (ap_cmp.on_confirm_done {; map <CR> on insert mode
                                         :map_cr false
                                         ; it will auto insert `()` after select function or method item
                                         :map_complete true
                                         ; automatically select the first item
                                         :auto_select true})))

{: config}
