(local {:keymap {:set kset}
        :api {: nvim_create_namespace
              : nvim_feedkeys
              : nvim_replace_termcodes
              : nvim_create_augroup
              : nvim_create_autocmd}
        :fn {: reg_recording : reg_recorded : getreg : setreg : col}
        :cmd {: normal}
        : on_key} vim)

;;; Bugs
;; arrow keys in insert mode do not work

(local namespace (nvim_create_namespace :MacroInsertPaste))

(local key-c-o (nvim_replace_termcodes :<C-o> true false true))
(local key-esc (nvim_replace_termcodes :<Esc> true false true))

(local key-right (nvim_replace_termcodes :<Right> true false true))

(local mode-key-map {:niI key-c-o})

(var insert-paste? false)

(lambda valid-reg? [reg]
  (string.match reg "^%a$"))

(fn insert-enter []
  (let [macro-register (reg_recording)
        is-end-of-line (= (col ".") (col "$"))]
    (when (and insert-paste? (valid-reg? macro-register))
      (normal {1 :q :bang true})
      (if is-end-of-line
          (nvim_feedkeys key-right :n false)))))

(fn insert-leave []
  (let [macro-register (string.lower (reg_recorded))]
    (when (and insert-paste? (valid-reg? macro-register)
               (not= vim.v.event.new_mode :c))
      (let [current-upper (string.upper macro-register)
            current-macro (getreg macro-register)
            inserted (getreg ".")
            mode-key (. mode-key-map vim.v.event.new_mode)
            key-to-leave (or mode-key key-esc)
            new-macro (.. current-macro inserted key-to-leave)]
        (setreg macro-register new-macro)
        (normal {1 (.. :q current-upper) :bang true})))))

(fn start-macro [use-insert-paste?]
  (set insert-paste? use-insert-paste?)
  :q)

(fn setup []
  (kset :n :<Leader>q #(start-macro true)
        {:expr true :desc "Macro insert paste"})
  (kset :n :q #(start-macro false) {:expr true :desc "Start macro"})
  (let [group (nvim_create_augroup :MacroInsertPaste {})]
    (nvim_create_autocmd :ModeChanged
                         {: group :pattern "*:i" :callback insert-enter})
    (nvim_create_autocmd :ModeChanged
                         {: group :pattern "i:*" :callback insert-leave})))

{: setup}
