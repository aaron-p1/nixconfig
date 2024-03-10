(local {:keymap {:set kset}} vim)

(fn config []
  (set vim.g.copilot_no_maps true)
  (set vim.g.copilot_filetypes {:TelescopePrompt false :DressingInput false})
  (kset :i :<C-o> "copilot#Accept(\"\")" {:expr true :replace_keycodes false})
  (kset :i :<C-S-o> "copilot#AcceptLine()" {:expr true :replace_keycodes false})
  (kset :i :<M-o> "copilot#AcceptWord()" {:expr true :replace_keycodes false})
  (kset :i "<M-[>" "<Cmd>call copilot#Previous()<CR>" {:silent true})
  (kset :i "<M-]>" "<Cmd>call copilot#Next()<CR>" {:silent true}))

{: config}
