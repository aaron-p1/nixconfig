(local {: nvim_create_namespace
        : nvim_get_hl_id_by_name
        : nvim_get_current_buf
        : nvim_win_get_cursor
        : nvim_buf_get_extmarks
        : nvim_buf_get_extmark_by_id
        : nvim_buf_set_extmark
        : nvim_buf_del_extmark
        : nvim_create_autocmd
        : nvim_create_augroup} vim.api)

(local {: stdpath
        : expand
        : substitute
        : delete
        : writefile
        : extend
        : readfile
        : getcwd
        : readdir
        : reduce
        : mkdir} vim.fn)

(local {:set kset} vim.keymap)

(local {:remove_index remove-index} (require :helper))

(local namespace (nvim_create_namespace :VirtNotes))
(local note-highlight (nvim_get_hl_id_by_name :WildMenu))
(local notes-path (.. (stdpath :data) :/virt_notes))

(var saved-note-id {})

(fn get-filename []
  (let [full-path (expand "%:p")
        filename (string.gsub full-path "/" "_")]
    (if (= full-path "") nil (.. notes-path "/" filename :.txt))))

(fn get-bufnr []
  (nvim_get_current_buf))

(fn get-line []
  (- (. (nvim_win_get_cursor 0) 1) 1))

(lambda remove-protocol [filename]
  (substitute filename "^\\(\\w\\+:__\\)\\?" "" ""))

(lambda get-extmarks [bufnr ?line]
  (let [[start end] (if (= ?line nil) [0 -1] [[?line 0] [?line 0]])]
    (nvim_buf_get_extmarks bufnr namespace start end {:details true})))

(lambda get-extmark-by-id [bufnr id]
  (match (nvim_buf_get_extmark_by_id bufnr namespace id {:details true})
    [row col details] [id row col details]
    _ nil))

(lambda set-extmark [bufnr text line ?id]
  (nvim_buf_set_extmark bufnr namespace line 0
                        {:id ?id :virt_text [[text note-highlight]]}))

(lambda remove-all-extmarks [bufnr ?line]
  (each [_ note (ipairs (get-extmarks bufnr ?line))]
    (nvim_buf_del_extmark bufnr namespace (. note 1))))

(lambda persist-notes [bufnr filename]
  (let [notes (get-extmarks bufnr)
        savable-lines (vim.tbl_map #(.. (. $1 2) " " (. $1 4 :virt_text 1 1))
                                   notes)]
    (if (= 0 (length notes))
        (delete filename)
        (writefile (extend [(expand "%:p")] savable-lines) filename))))

(lambda parse-notes-file [lines]
  "Needs to have at least one line with filename"
  (let [src-file (. lines 1)
        note-lines (remove-index lines 1)
        entries (vim.tbl_map #[(string.match $1 "^([^ ]*) (.*)")] note-lines)]
    [(vim.tbl_map #[(tonumber (. $1 1)) (. $1 2)] entries) src-file]))

(lambda get-notes-from-file [?filename]
  (match (pcall readfile ?filename)
    (where (true content) (> (length content) 1)) (parse-notes-file content)
    _ [[] nil]))

(lambda load-notes [bufnr ?filename]
  (remove-all-extmarks bufnr)
  (each [_ entry (ipairs (. (get-notes-from-file ?filename) 1))]
    (set-extmark bufnr (. entry 2) (. entry 1))))

(lambda sel-notes-on-cur-line [bufnr callback]
  (match (get-extmarks bufnr (get-line))
    (where notes (< 1 (length notes))) (vim.ui.select notes
                                                      {:prompt "Select extmark"
                                                       :format_item #(. $1 4
                                                                        :virt_text
                                                                        1 1)}
                                                      #(if (not= $1 nil)
                                                           (callback $1)))
    [entry] (callback entry)
    [] nil))

(fn get-project-files []
  (let [clean-cwd (string.gsub (getcwd) "/" "_")
        (has-files? notes-files) (pcall readdir notes-path)]
    (if (or (= clean-cwd nil) (not has-files?)) []
        (vim.tbl_filter #(vim.startswith (remove-protocol $1) clean-cwd)
                        notes-files))))

(fn get-notes-from-files []
  (let [files (get-project-files)
        entries (vim.tbl_map (fn [file]
                               (let [filename (.. notes-path "/" file)
                                     file-entries (get-notes-from-file filename)]
                                 (vim.tbl_map #[(. file-entries 2) $1]
                                              (. file-entries 1))))
                             files)]
    (reduce entries #(extend $1 $2) [])))

(lambda note->telescope-entry [cwd note]
  (let [path (string.sub (remove-protocol (. note 1)) (+ 2 (length cwd)))]
    {:value (. note 2)
     :display (.. path " | " (. note 2 2))
     :ordinal (.. path " " (. note 2 1) " " (. note 2 2))
     :path (. note 1)
     :lnum (+ 1 (. note 2 1))}))

(lambda save-note [bufnr line text ?filename ?id]
  (set-extmark bufnr text line ?id)
  (when (not= ?filename nil)
    (persist-notes bufnr ?filename)))

(fn add-note []
  (let [filename (get-filename)
        bufnr (get-bufnr)
        line (get-line)]
    (vim.ui.input {:prompt "Add note: "}
                  #(if (not= $1 nil)
                       (save-note bufnr line $1 filename)))))

(fn edit-note []
  (let [filename (get-filename)
        bufnr (get-bufnr)]
    (sel-notes-on-cur-line bufnr
                           (fn [note]
                             (vim.ui.input {:prompt "Edit note: "
                                            :default (. note 4 :virt_text 1 1)}
                                           #(if (not= $1 nil)
                                                (save-note bufnr (. note 2) $1
                                                           filename (. note 1))))))))

(fn remove-note []
  (let [filename (get-filename)
        bufnr (get-bufnr)]
    (sel-notes-on-cur-line bufnr
                           #(do
                              (nvim_buf_del_extmark bufnr namespace (. $1 1))
                              (when (not= filename nil)
                                (persist-notes bufnr filename))))))

(fn remove-all-notes []
  (let [filename (get-filename)
        bufnr (get-bufnr)]
    (remove-all-extmarks bufnr (get-line))
    (when (not= filename nil)
      (persist-notes bufnr filename))))

(fn remove-all-notes-in-file []
  (let [filename (get-filename)
        bufnr (get-bufnr)]
    (remove-all-extmarks bufnr)
    (when (not= filename nil)
      (persist-notes bufnr filename))))

(fn move-note []
  (let [bufnr (get-bufnr)]
    (sel-notes-on-cur-line bufnr
                           #(do
                              (tset saved-note-id bufnr (. $1 1))
                              (print (.. "Moving note: "
                                         (. $1 4 :virt_text 1 1)))))))

(fn paste-note []
  (let [filename (get-filename)
        bufnr (get-bufnr)]
    (match-try (?. saved-note-id bufnr) (where id (not= id nil))
               (get-extmark-by-id bufnr id) [_ _ _ {:virt_text [[note-text]]}]
               (save-note bufnr (get-line) note-text filename id)
               (catch nil (print "No note selected")))))

(fn get-notes-in-project []
  (let [p (require :telescope.pickers)
        f (require :telescope.finders)
        {:values config} (require :telescope.config)
        t (require :telescope.themes)
        opts {}
        cwd (getcwd)]
    (: (p.new opts {:prompt_title "Notes in project"
                    :finder (f.new_table {:results (get-notes-from-files)
                                          :entry_maker (partial note->telescope-entry
                                                                cwd)})
                    :sorter (config.generic_sorter opts)
                    :previewer (config.grep_previewer opts)}) :find)))

(fn setup []
  (mkdir notes-path :p)
  (kset :n :<Leader>va add-note {:desc :Add})
  (kset :n :<Leader>ve edit-note {:desc :Edit})
  (kset :n :<Leader>vdd remove-note {:desc "Delete on line"})
  (kset :n :<Leader>vda remove-all-notes {:desc "Delete all on line"})
  (kset :n :<Leader>vdf remove-all-notes-in-file {:desc "Delete all in file"})
  (kset :n :<Leader>vx move-note {:desc :Move})
  (kset :n :<Leader>vp paste-note {:desc :Paste})
  (kset :n :<Leader>fv get-notes-in-project {:desc "Virtual notes"})
  (let [group (nvim_create_augroup :VirtNotes {:clear true})]
    (nvim_create_autocmd :BufRead
                         {: group
                          :callback #(load-notes (get-bufnr) (get-filename))})
    (nvim_create_autocmd :BufWrite
                         {: group
                          :callback #(persist-notes (get-bufnr) (get-filename))})))

{: setup}
