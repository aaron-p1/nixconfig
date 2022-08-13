(local {: startswith} vim)

(local {: remove_suffix} (require :helper))

(local remotes-file :extra/secrets/comparable_remotes.json)

;; TODO format
(fn read-remotes-file []
  (match-try (vim.api.nvim_get_runtime_file remotes-file false)
             ;; read content of file
             [file] (pcall vim.fn.readfile file) ;; parse json
             (true content) (pcall vim.fn.json_decode content)
             ;; return list of remotes
             (true result) result (catch ;; no runtime file found
                                        [] {} ;; pcall error
                                        (_ msg)
                                        (do
                                          (print "Error reading comparable remotes file:"
                                                 msg)
                                          {})
                                        ;; other error
                                        mismatch
                                        (do
                                          (print "Mismatch in comparable remotes: "
                                                 (vim.inspect mismatch))
                                          {}))))

;; convert to table
(local remotes (icollect [name path-map (pairs (read-remotes-file))]
                 [name path-map]))

(fn open-remote-selection [local-path]
  (vim.ui.select remotes
                 {:prompt (.. "Select remote to compare " local-path :to)
                  :format_item (fn [remote]
                                 (. remote 1))}
                 (fn [choice]
                   (when (not= choice nil)
                     (vim.cmd "silent tab split")
                     (vim.cmd (.. "silent vertical diffsplit " (. choice 2)
                                  local-path))))))

(fn compare-remotes []
  (let [cwd (vim.fn.getcwd)
        filename (vim.fn.expand "%:p")
        local-path (-> (vim.fn.system (.. "realpath --relative-base='" cwd
                                          "' '" filename "'"))
                       (remove_suffix "\n"))]
    (if (startswith local-path "/")
        (vim.cmd (.. "echoerr 'Not a project file: " local-path "'"))
        (open-remote-selection local-path))))

(fn setup []
  (vim.keymap.set :n :<Leader>cr compare-remotes {:desc "Remote File"}))

{: setup}
