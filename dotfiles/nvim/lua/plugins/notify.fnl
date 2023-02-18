(local {:keymap {:set kset}} vim)

(local {: load_extension : extensions} (require :telescope))

(local new-notify (require :notify))

(fn config []
  (set vim.notify new-notify)
  (load_extension :notify)
  (kset :n :<Leader>fn extensions.notify.notify {:desc :Notifications}))

{: config}
