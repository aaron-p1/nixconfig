(local {:keymap {:set kset}
        :fn {"cmake4vim#GenerateCMake" generate-cmake
             "cmake4vim#RunTarget" run-target}} vim)

(local {:register_plugin_wk register-plugin-wk} (require :helper))

(fn config []
  (kset :n :<Leader>ec generate-cmake {:desc :Generate})
  (kset :n :<Leader>er #(run-target 0) {:desc :Run})
  (register-plugin-wk {:prefix :<Leader> :map {:e {:name :Run}}}))

{: config}
