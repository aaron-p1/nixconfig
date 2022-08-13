(local {: register_plugin_wk} (require :helper))

(local log-count 50)

(let [maps {:p :pull
            :f :fetch
            :P :push
            :l (.. "log -" log-count)
            :L (.. "log -" (* log-count 2))}]
  (each [key command (pairs maps)]
    (vim.keymap.set :n (.. :<Leader>g key) (.. "<Cmd>Git " command :<CR>)
                    {:buffer true})))

(register_plugin_wk {:prefix :<Leader>
                     :buffer 0
                     :map {:g {:name :Git
                               :p :Pull
                               :f :Fetch
                               :P :Push
                               :l (.. "Log " log-count)
                               :L (.. "Log " (* log-count 2))}}})
