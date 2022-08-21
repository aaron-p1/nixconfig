(local {: s : p} (require :plugins.luasnip.snippets.utils))

;; Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
(lambda run-in-shell [command]
  (with-open [stdout (io.popen command :r)]
    (icollect [line (stdout:lines)]
      line)))

(lambda shell-snippet [trig command]
  (s trig (p run-in-shell command)))

[(shell-snippet :uuidgen :uuidgen)
 (shell-snippet :date "date --iso-8601")
 (shell-snippet :datetime "date --rfc-3339=seconds")
 (shell-snippet :datetimei "date --iso-8601=seconds")]
