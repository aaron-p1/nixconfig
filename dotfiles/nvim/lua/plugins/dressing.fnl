(local {: nvim_set_hl} vim.api)

(local {: setup} (require :dressing))
(local {: get_dropdown} (require :telescope.themes))

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
  (let [dropdown-config {:layout_config {:width get-select-float-width
                                         :height get-select-float-height}}]
    (setup {:input {:insert_only false
                    :start_in_insert true
                    :win_options {:winblend 0}
                    :min_width [70 0.2]
                    :get_config #(if $1.center {:relative :editor} nil)}
            :select {:backend [:telescope :builtin]
                     :telescope (get_dropdown dropdown-config)}})))

{: config}
