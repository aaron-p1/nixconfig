(local {:keymap {:set kset}} vim)

(local {: load_extension : extensions} (require :telescope))

(fn config []
  (load_extension :cmake4vim)
  (let [{: select_target : select_build_type} extensions.cmake4vim]
    (kset :n :<Leader>est select_target {:desc "Select target"})
    (kset :n :<Leader>esb select_build_type {:desc "Select build type"})))

{: config}
