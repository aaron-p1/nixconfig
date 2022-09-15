(local {: tbl_extend : startswith} vim)
(local {: nvim_get_runtime_file : nvim_get_current_tabpage} vim.api)
(local {: split : diffsplit : echoerr} vim.cmd)
(local {: readfile : getcwd : expand} vim.fn)
(local {:decode jdecode} vim.json)
(local {:set kset} vim.keymap)

(local {: map} (require :helper))
(local {: profiles} (require :profiles))

(local remotes-file :extra/secrets/comparable-remotes.json)
(local remote-keys [:all (unpack profiles)])

(fn read-remotes-file []
  (let [[file] (nvim_get_runtime_file remotes-file false)
        content (with-open [fd (io.input file)]
                  (fd:read :*a))]
    (jdecode content)))

(fn collect-remotes []
  (let [file-content (match (pcall read-remotes-file)
                       (true content) content
                       _ {})
        remotes-list (map remote-keys #(or (. file-content $1) []))]
    (tbl_extend :force {} {} (unpack remotes-list))))

;; convert to list
(local remotes (icollect [name path-map (pairs (collect-remotes))]
                 [name path-map]))

(fn open-remote-selection [local-path]
  (vim.ui.select remotes {:prompt (.. "Select remote to compare " local-path
                                      " against")
                          :format_item (fn [[name]]
                                         name)}
                 (fn [choice]
                   (when (not= choice nil)
                     (let [tab (nvim_get_current_tabpage)
                           [_ remote-prefix] choice
                           remote-path (.. remote-prefix local-path)]
                       (split {:mods {: tab :silent true}})
                       (diffsplit {1 remote-path
                                   :mods {:vertical true :silent true}}))))))

(fn compare-remotes []
  (let [cwd (getcwd)
        local-path (expand "%:.")]
    (if (startswith local-path "/")
        (echoerr (.. "Not a project file: " local-path))
        (open-remote-selection local-path))))

(fn setup []
  (kset :n :<Leader>cr compare-remotes {:desc "Remote File"}))

{: setup}
