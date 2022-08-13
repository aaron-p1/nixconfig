(fn config []
  (local ib (require :indent_blankline))
  (ib.setup {:filetype_exclude [:help :packer]
             :use_treesitter true
             :show_current_context true
             :show_current_context_start true}))

{: config}
