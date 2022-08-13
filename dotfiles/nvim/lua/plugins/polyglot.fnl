(local {: filereadable : getcwd} vim.fn)

(fn setup []
  (when (= 1 (filereadable (.. (getcwd) :/.editorconfig)))
    (set vim.g.polyglot_disabled [:autoindent])))

{: setup}
