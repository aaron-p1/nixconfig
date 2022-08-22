(local {:set kset} vim.keymap)

(local dc (require :dial.config))
(local dm (require :dial.map))
(local {:integer {:alias {:decimal_int int-dec
                          :hex int-hex
                          :octal int-oct
                          :binary int-bin}}
        :date {:alias {"%Y-%m-%d" date-iso
                       "%d.%m.%Y" date-de
                       "%d.%m.%y" date-de-short
                       "%H:%M:%S" date-time
                       "%H:%M" date-time-short}}
        :constant {:alias {:bool const-bool
                           :alpha const-alpha
                           :Alpha const-Alpha}
                   &as const}
        :semver {:alias {: semver}}
        :hexcolor col} (require :dial.augend))

(local const-cond (const.new {:elements [:and :or] :word true :cyclic true}))
(local const-cond-short (const.new {:elements ["&&" "||"]
                                    :word false
                                    :cyclic true}))

(local col-lower (col.new {:case :lower}))

(fn config []
  (dc.augends:register_group {:default [; builtin
                                        int-dec
                                        int-hex
                                        int-oct
                                        int-bin
                                        date-iso
                                        date-de
                                        date-de-short
                                        date-time
                                        date-time-short
                                        const-bool
                                        const-alpha
                                        const-Alpha
                                        semver
                                        ; custom
                                        const-cond
                                        const-cond-short
                                        col-lower]})
  (kset :n :<C-A> (dm.inc_normal) {})
  (kset :n :<C-X> (dm.dec_normal) {})
  (kset :v :<C-A> (dm.inc_visual) {})
  (kset :v :<C-X> (dm.dec_visual) {})
  (kset :v :g<C-A> (dm.inc_gvisual) {})
  (kset :v :g<C-X> (dm.dec_gvisual) {}))

{: config}
