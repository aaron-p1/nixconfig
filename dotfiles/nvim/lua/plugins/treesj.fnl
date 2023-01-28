(local {:api {: nvim_buf_get_option : nvim_create_autocmd} :keymap {:set kset}}
       vim)

(local {: setup : split : join} (require :treesj))
(local {:presets langs} (require :treesj.langs))

(fn map-right-plugin [{:buf bufnr}]
  (let [opts {:buffer bufnr}
        ft (nvim_buf_get_option bufnr :filetype)
        [split-action join-action] (if (. langs ft) [split join]
                                       [:<Cmd>SplitjoinSplit<Cr>
                                        :<Cmd>SplitjoinJoin<Cr>])]
    (kset :n :gS split-action opts)
    (kset :n :gJ join-action opts)))

(fn config []
  (setup {:use_default_keymaps false})
  (nvim_create_autocmd :FileType {:pattern "*" :callback map-right-plugin}))

{: config}
