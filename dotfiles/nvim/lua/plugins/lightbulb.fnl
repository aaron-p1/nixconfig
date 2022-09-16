(local {: nvim_create_augroup : nvim_create_autocmd} vim.api)

(local {: setup : update_lightbulb} (require :nvim-lightbulb))

(fn config []
  (setup {})
  (let [group (nvim_create_augroup :Lightbulb {})]
    (nvim_create_autocmd [:CursorHold :CursorHoldI]
                         {: group :callback update_lightbulb})))

{: config}
