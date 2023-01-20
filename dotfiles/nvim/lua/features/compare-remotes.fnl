(local {: tbl_extend
        : startswith
        :api {: nvim_get_runtime_file
              : nvim_tabpage_get_number
              : nvim_get_current_tabpage}
        :cmd {: split : diffsplit : echoerr}
        :fn {: readfile : getcwd : expand : fnamemodify : glob : isdirectory}
        :json {:decode jdecode}
        :keymap {:set kset}} vim)

(local {: map} (require :helper))
(local {: profiles} (require :profiles))

(local remotes-file :extra/secrets/comparable-remotes.json)
(local remote-keys [:all (unpack profiles)])

(local schema-replacements {:file {} :dir {:scp :oil-ssh}})

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

(lambda replace-schema [path replacements]
  (let [schema (string.gsub path "^(.+)://.+$" "%1")
        replacement (. replacements schema)]
    (if replacement
        (string.gsub path "^.+://" (.. replacement "://"))
        path)))

(lambda get-remote-path [remote-prefix path dir?]
  (let [replacements (. schema-replacements (if dir? :dir :file))
        path-prefix (replace-schema remote-prefix replacements)]
    (.. path-prefix path)))

(fn entry-selected [local-path choice]
  (when choice
    (let [[_ remote-prefix] choice
          dir? (= 1 (isdirectory local-path))
          remote-path (get-remote-path remote-prefix local-path dir?)
          tab (nvim_tabpage_get_number (nvim_get_current_tabpage))]
      (split {:mods {: tab :silent true}})
      (diffsplit {1 remote-path :mods {:vertical true :silent true}}))))

(lambda open-remote-selection [local-path]
  (let [prompt (.. "Select remote to compare " local-path " against")]
    (vim.ui.select remotes {: prompt :format_item #(. $1 1)}
                   (partial entry-selected local-path))))

(lambda buf-path->local-path [buf-path]
  (let [path-without-scheme (string.gsub buf-path "^%l+://" "")
        local-path (fnamemodify path-without-scheme ":.")]
    (if (or (= "" (glob local-path)) (startswith local-path "/")) nil
        local-path)))

(fn compare-remotes []
  (let [buf-path (expand "%:p")
        local-path (buf-path->local-path buf-path)]
    (if local-path
        (open-remote-selection local-path)
        (echoerr (.. "Not a project file: " buf-path)))))

(fn setup []
  (kset :n :<Leader>cr compare-remotes {:desc "Compare remote File"}))

{: setup}
