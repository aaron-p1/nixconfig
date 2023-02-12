(local {:set kset} vim.keymap)

(local {:register wk-register} (require :plugins.which-key))

(local {: setup : toggle : eval} (require :dapui))

(fn config []
  (setup {:icons {:expanded "▾" :collapsed "▸"}
          :mappings {:expand :<CR> :open :o :remove :d :edit :e}
          :sidebar {:open_on_start true
                    :elements [:scopes :breakpoints :stacks :watches]
                    :width 60
                    :position :left}
          :tray {:open_on_start true
                 :elements [:repl]
                 :height 10
                 :position :bottom}
          :floating {:max_height nil :max_width nil}})
  (kset :n :<Leader>dd toggle {:desc "Toggle UI"})
  (kset [:n :v] :<Leader>de eval {:desc "Toggle eval"})
  (wk-register {:prefix :<Leader> :map {:d {:name :dap}}}))

{: config}
