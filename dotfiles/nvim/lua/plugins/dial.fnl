(local {:set kset} vim.keymap)

(local {: augends} (require :dial.config))
(local {: inc_normal
        : dec_normal
        : inc_visual
        : dec_visual
        : inc_gvisual
        : dec_gvisual} (require :dial.map))
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
  (augends:register_group {:default [; builtin
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
  (kset :n :<C-A> (inc_normal) {})
  (kset :n :<C-X> (dec_normal) {})
  (kset :v :<C-A> (inc_visual) {})
  (kset :v :<C-X> (dec_visual) {})
  (kset :v :g<C-A> (inc_gvisual) {})
  (kset :v :g<C-X> (dec_gvisual) {}))

{: config}
