(local {: tbl_extend :api {: nvim_get_runtime_file} :json {:decode jdecode}}
       vim)

(local {: map} (require :helper))
(local {: profiles} (require :profiles))

(local {: setup} (require :compare-remotes))

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
        remotes-list (map remote-keys #(or (. file-content $1) {}))]
    (tbl_extend :force {} {} (unpack remotes-list))))

(fn config []
  (setup {:remotes (collect-remotes)
          :project_file_schemes [:oil]
          :scheme_replacements {:dir {:scp :oil-ssh}}
          :mapping {:key :<Leader>cr}}))

{: config}
