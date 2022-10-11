(local {:load load-snippets} (require :luasnip.loaders.from_vscode))

(fn config []
  (load-snippets {:include [:cpp]}))

{: config}
