; TODO convert to kebab-case
(local {:registerPluginWk register-plugin-wk} (require :helper))

(local log-count :25)

(let [maps {:p :pull :f :fetch :P :push :l (.. "log -" log-count)}]
  (each [key command (pairs maps)]
    (vim.keymap.set :n (.. :<Leader>g key) (.. "<Cmd>Git " command :<CR>)
                    {:buffer true})))

(register-plugin-wk {:prefix :<Leader>
                     :buffer 0
                     :map {:g {:name :Git
                               :p :Pull
                               :f :Fetch
                               :P :Push
                               :l (.. "Log " log-count)}}})
