(fn config []
  (tset vim.g :copilot_no_tab_map true)
  (vim.keymap.set :i :<C-o> "copilot#Accept(\"<C-o>\")"
                  {:noremap true
                   :silent true
                   :expr true
                   :replace_keycodes false}))

{: config}
