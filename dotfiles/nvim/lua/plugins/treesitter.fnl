(fn config []
  (local tsc (require :nvim-treesitter.configs))
  (tsc.setup {:highlight {:enable true}
              :indent {:enable true}
              :autotag {:enable true :filetypes [:html :xml :blade :vue]}}))

{: config}
