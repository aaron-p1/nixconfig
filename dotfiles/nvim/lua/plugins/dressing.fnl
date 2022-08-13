(local {: nvim_set_hl} vim.api)

(local select-float-min-width 80)
(local select-float-width-factor 0.8)
(local select-float-min-height 15)
(local select-float-height-factor 0.9)

(fn get-select-float-width [_ max-cols]
  (math.min max-cols (math.max select-float-min-width
                               (math.floor (* select-float-width-factor
                                              max-cols)))))

(fn get-select-float-height [_ _ max-rows]
  (math.min max-rows (math.max select-float-min-height
                               (math.floor (* select-float-height-factor
                                              max-rows)))))

(fn config []
  (local d (require :dressing))
  (local t (require :telescope))
  (local tt (require :telescope.themes))
  (nvim_set_hl 0 :FloatBorder {:link :TelescopeBorder})
  (nvim_set_hl 0 :FloatTitle {:link :TelescopeTitle})
  (let [dropdown-config {:layout_config {:width get-select-float-width
                                         :height get-select-float-height}}]
    (d.setup {:input {:insert_only false :winblend 0 :min_width [70 0.2]}
              :select {:backend [:telescope :builtin]
                       :telescope (tt.get_dropdown dropdown-config)}})))

{: config}
