(local {:set kset} vim.keymap)

(local enabled-spell-langs [:de :en])
(local spell-dir (.. (vim.fn.stdpath :config) :/spell))

(fn enable-spell []
  (vim.ui.select enabled-spell-langs {:prompt "Select spelllang"}
                 (fn [choice]
                   (when (not= nil choice)
                     (set vim.opt_local.spelllang choice)
                     (set vim.opt_local.spellfile
                          (.. spell-dir "/" choice :.utf-8.add))
                     (set vim.opt_local.spell true)))))

(fn config []
  (kset :n "[os" enable-spell {:desc "Enable spell"}) ; ]
  (kset :n :yos
        #(if vim.o.spell (set vim.opt_local.spell false) (enable-spell))
        {:desc "Toggle spell"}))

{: config}
