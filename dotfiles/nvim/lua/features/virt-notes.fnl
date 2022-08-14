(local {: startswith : ui} vim)

(local {: nvim_create_namespace
        : nvim_get_hl_id_by_name
        : nvim_set_hl
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

(local {: index_of
        : flatmap
        : map
        : remove_index
        : group_by
        : concat
        : filter
        : remove_prefix} (require :helper))

(local namespace (nvim_create_namespace :VirtNotes))
(local note-highlight (nvim_get_hl_id_by_name :VirtNote))
(local notes-path (.. (stdpath :data) :/virt_notes))

(var saved-note-id {})
(var notes-in-buffer {})

(local actions [])

(nvim_set_hl 0 :VirtNote {:default true :link :WildMenu})

;; TODO change file name handling
(fn get-file []
  (match (expand "%:p")
    "" nil
    file file))

(lambda file->notes-file [file]
  (.. notes-path "/" (string.gsub file "/" "_") :.txt))

(fn get-bufnr []
  (nvim_get_current_buf))

(fn get-line []
  (- (. (nvim_win_get_cursor 0) 1) 1))

(lambda get-notes [bufnr]
  (match (. notes-in-buffer bufnr)
    n n
    nil []))

(lambda set-notes [bufnr notes]
  (tset notes-in-buffer bufnr notes))

(lambda get-notes-on-line [bufnr line]
  (match (?. (get-notes bufnr) line)
    n n
    nil []))

(lambda set-notes-on-line [bufnr line notes]
  (let [existing (get-notes bufnr)
        new-on-line (if (= 0 (length notes))
                        nil
                        notes)]
    (if (= nil existing)
        (set-notes bufnr {line new-on-line})
        (tset existing line new-on-line))))

(lambda get-note-index [bufnr line note]
  (match (get-notes-on-line bufnr line)
    notes (index_of notes note)
    nil nil))

(lambda get-note-text [bufnr line index]
  (match (get-notes-on-line bufnr line)
    notes (. notes index)
    nil nil))

(lambda add-note [bufnr line note]
  (let [existing (get-notes-on-line bufnr line)]
    (set-notes-on-line bufnr line (concat existing [note]))))

;; fnlfmt: skip
(lambda rename-note [bufnr line old new]
  (match-try (get-notes-on-line bufnr line)
    notes (index_of notes old)
    index (tset notes index new)))

;; fnlfmt: skip
(lambda remove-note [bufnr line note]
  (match-try (get-notes-on-line bufnr line)
    notes (index_of notes note)
    index (remove_index notes index)
    remaining (set-notes-on-line bufnr line remaining)))

;; fnlfmt: skip
(lambda remove-note-index [bufnr line index]
  (match-try (get-notes-on-line bufnr line)
    notes (remove_index notes index)
    remaining (set-notes-on-line bufnr line remaining)))

(lambda remove-protocol [notes-file]
  (substitute notes-file "^\\(\\w\\+:__\\)\\?" "" ""))

(lambda get-extmarks [bufnr ?line]
  (let [[start end] (if (= ?line nil) [0 -1] [[?line 0] [?line 0]])]
    (nvim_buf_get_extmarks bufnr namespace start end {:details true})))

(lambda set-extmark [bufnr text line ?id]
  (nvim_buf_set_extmark bufnr namespace line 0
                        {:id ?id :virt_text [[text note-highlight]]}))

(lambda remove-all-extmarks [bufnr ?line]
  (each [_ note (ipairs (get-extmarks bufnr ?line))]
    (nvim_buf_del_extmark bufnr namespace (. note 1))))

;; TODO check if reverse order
(lambda draw-line [bufnr line notes-on-line]
  (remove-all-extmarks bufnr line)
  (each [_ note (ipairs notes-on-line)]
    (set-extmark bufnr note line)))

(lambda draw-buffer [bufnr]
  (remove-all-extmarks bufnr)
  (each [line notes (pairs (get-notes bufnr))]
    (draw-line bufnr line notes)))

(lambda redraw-line [bufnr line]
  (draw-line bufnr line (get-notes-on-line bufnr line)))

(lambda persist-notes [bufnr file]
  (let [savable-notes (flatmap (get-notes bufnr)
                               (fn [notes line]
                                 (map notes #[line $1])))
        savable-lines (map savable-notes #(.. (. $1 1) " " (. $1 2)))
        notes-file (file->notes-file file)]
    (if (= 0 (length savable-lines))
        (delete notes-file)
        (writefile (concat [file] savable-lines) notes-file))))

(lambda parse-notes-file [lines]
  "Needs to have at least one line with filename"
  (let [file (. lines 1)
        note-lines (remove_index lines 1)
        entries (map note-lines #[(string.match $1 "^([^ ]*) (.*)")])]
    [file (map entries #[(tonumber (. $1 1)) (. $1 2)])]))

(lambda get-notes-from-file [notes-file]
  (match (pcall readfile notes-file)
    (true [l &as lines]) (parse-notes-file lines)
    _ [nil []]))

(lambda load-notes [bufnr file]
  (let [notes-file (file->notes-file file)
        [_ note-entries] (get-notes-from-file notes-file)]
    (set-notes bufnr (group_by note-entries #(. $1 1) #(. $1 2)))
    (draw-buffer bufnr)))

(lambda sel-notes-on-line [bufnr line callback]
  (match (get-notes-on-line bufnr line)
    [x y &as notes] (ui.select notes {:prompt "Select extmark"}
                               #(if (not= $1 nil)
                                    (callback $1)))
    [entry] (callback entry)
    _ nil))

(fn get-project-files [cwd]
  (let [clean-cwd (string.gsub cwd "/" "_")
        (has-files? notes-files) (pcall readdir notes-path)]
    (if (and (not= nil clean-cwd) has-files?)
        (filter notes-files #(startswith $1 clean-cwd))
        [])))

(fn get-notes-from-files [cwd]
  "Return [file [line text]]"
  (let [files (get-project-files cwd)]
    (flatmap files (fn [nfname]
                     (let [notes-file (.. notes-path "/" nfname)
                           [file notes] (get-notes-from-file notes-file)]
                       (map notes #[file $1]))))))

(lambda note->telescope-entry [cwd note]
  (let [[file [line text]] note
        path (remove_prefix file (.. cwd "/"))]
    {:value note
     :display (.. path " | " text)
     :ordinal (.. path " " line " " text)
     :path file
     :lnum (+ 1 line)}))

(lambda sync-line [bufnr ?file line]
  (redraw-line bufnr line)
  (when (not= ?file nil)
    (persist-notes bufnr ?file)))

(lambda sync-file [bufnr ?file]
  (draw-buffer bufnr)
  (when (not= ?file nil)
    (persist-notes bufnr ?file)))

(lambda add-callback [bufnr line ?file ?input]
  (when (not= nil ?input)
    (add-note bufnr line ?input)
    (sync-line bufnr ?file line)))

(lambda edit-callback [bufnr line ?file old ?input]
  (when (not= nil ?input)
    (rename-note bufnr line old ?input)
    (sync-line bufnr ?file line)))

(lambda remove-callback [bufnr line ?file ?input]
  (when (not= nil ?input)
    (remove-note bufnr line ?input)
    (sync-line bufnr ?file line)))

(fn actions.add-note []
  (let [file (get-file)
        bufnr (get-bufnr)
        line (get-line)]
    (ui.input {:prompt "Add note: "} (partial add-callback bufnr line file))))

(fn actions.edit-note []
  (let [file (get-file)
        bufnr (get-bufnr)
        line (get-line)]
    (sel-notes-on-line bufnr line
                       #(ui.input {:prompt "Edit note: " :default $1}
                                  (partial edit-callback bufnr line file $1)))))

(fn actions.remove-note []
  (let [file (get-file)
        bufnr (get-bufnr)
        line (get-line)]
    (sel-notes-on-line bufnr line (partial remove-callback bufnr line file))))

(fn actions.remove-all-notes []
  (let [file (get-file)
        bufnr (get-bufnr)
        line (get-line)]
    (set-notes-on-line bufnr line [])
    (sync-line bufnr file line)))

(fn actions.remove-all-notes-in-file []
  (let [file (get-file)
        bufnr (get-bufnr)]
    (set-notes bufnr [])
    (sync-file bufnr file)))

(fn actions.move-note []
  (let [bufnr (get-bufnr)
        line (get-line)]
    (sel-notes-on-line bufnr line
                       #(do
                          (tset saved-note-id bufnr
                                [line (get-note-index bufnr line $1)])
                          (print (.. "Moving note: " $1))))))

;; fnlfmt: skip
(fn actions.paste-note []
  (let [file (get-file)
        bufnr (get-bufnr)
        line (get-line)]
    (match-try (. saved-note-id bufnr)
               [oldline oldindex] (get-note-text bufnr oldline oldindex)
               text (do
                      (remove-note-index bufnr oldline oldindex)
                      (add-note bufnr line text)
                      (sync-line bufnr file oldline)
                      (sync-line bufnr file line))
               (catch nil (print "No note selected")))))

(fn actions.get-notes-in-project []
  (let [p (require :telescope.pickers)
        f (require :telescope.finders)
        {:values config} (require :telescope.config)
        t (require :telescope.themes)
        opts {}
        cwd (getcwd)]
    (: (p.new opts {:prompt_title "Notes in project"
                    :finder (f.new_table {:results (get-notes-from-files cwd)
                                          :entry_maker (partial note->telescope-entry
                                                                cwd)})
                    :sorter (config.generic_sorter opts)
                    :previewer (config.grep_previewer opts)}) :find)))

(fn setup []
  (local a actions)
  (mkdir notes-path :p)
  (kset :n :<Leader>va a.add-note {:desc :Add})
  (kset :n :<Leader>ve a.edit-note {:desc :Edit})
  (kset :n :<Leader>vdd a.remove-note {:desc "On line"})
  (kset :n :<Leader>vda a.remove-all-notes {:desc "All on line"})
  (kset :n :<Leader>vdf a.remove-all-notes-in-file {:desc "All in file"})
  (kset :n :<Leader>vx a.move-note {:desc :Move})
  (kset :n :<Leader>vp a.paste-note {:desc :Paste})
  (kset :n :<Leader>fv a.get-notes-in-project {:desc "Virtual notes"})
  (let [group (nvim_create_augroup :VirtNotes {:clear true})]
    (nvim_create_autocmd :BufRead
                         {: group
                          :callback #(let [file (get-file)]
                                       (if (not= nil file)
                                           (load-notes (get-bufnr) file)))})
    (nvim_create_autocmd :BufWrite
                         {: group
                          :callback #(let [file (get-file)]
                                       (if (not= nil file)
                                           (persist-notes (get-bufnr) file)))})))

{: setup}
