(local {:keymap {:set kset}} vim)

(local {: load_extension : extensions} (require :telescope))

(local {: setup &as new-notify} (require :notify))
(local {: available_slot : slot_after_previous :DIRECTION {:TOP_DOWN top-down}}
       (require :notify.stages.util))

(lambda window-options [state]
  (let [height (+ state.message.height 2)
        row (available_slot state.open_windows height top-down)]
    (if row {:relative :editor
             :anchor :NE
             :width state.message.width
             :height state.message.height
             :col (vim.opt.columns:get)
             : row
             :border :rounded
             :style :minimal})))

(lambda slide-up [state win]
  {:row {1 (slot_after_previous win state.open_windows top-down)
         :frequency 6
         :complete #true}
   :col [(vim.opt.columns:get)]
   :time true})

(fn config []
  (set vim.notify new-notify)
  (setup {:stages [window-options slide-up] :timeout 3000})
  (load_extension :notify)
  (kset :n :<Leader>fn extensions.notify.notify {:desc :Notifications}))

{: config}
