(fn config []
  (local ui (require :dapui))
  (local {: register_plugin_wk} (require :helper))
  (ui.setup {:icons {:expanded "▾" :collapsed "▸"}
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
  (vim.keymap.set :n :<Leader>dd ui.toggle {:desc "Toggle UI"})
  (vim.keymap.set [:n :v] :<Leader>de ui.eval {:desc "Toggle eval"})
  (register_plugin_wk {:prefix :<Leader> :map {:d {:name :dap}}}))

{: config}
