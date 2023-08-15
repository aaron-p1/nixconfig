(local {:set kset} vim.keymap)

(local {: set_options} (require :helper))
(local {:register wk-register} (require :plugins.which-key))

(local log-count 50)

(set_options vim.opt_local {:foldmethod :syntax})

(let [maps {:p :pull
            :f :fetch
            :P :push
            :l (.. "log -" log-count)
            :L (.. "log -" (* log-count 2))}]
  (each [key command (pairs maps)]
    (kset :n (.. :<Leader>g key) (.. "<Cmd>Git " command :<CR>) {:buffer true})))

(kset :n :cO<Space> ":Git switch " {:buffer true})

(wk-register {:buffer 0
              :prefix :<Leader>
              :map {:g {:name :Git
                        :p :Pull
                        :f :Fetch
                        :P :Push
                        :l (.. "Log " log-count)
                        :L (.. "Log " (* log-count 2))}}})

(wk-register {:buffer 0 :prefix :c :map {:O {:name "Switch branch"}}})
