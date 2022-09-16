(local {: defer_fn
        :api {: nvim_create_namespace
              : nvim_get_current_buf
              : nvim_buf_clear_namespace
              : nvim_buf_get_text}
        :highlight {:range h-range}
        :keymap {:set kset}
        :lsp {:util {: apply_text_edits}}} vim)

(local {: get-operator-range} (require :helper))

(local namespace (nvim_create_namespace :SwapTextobjects))
(local highlight :IncSearch)

;; {:bufnr [startrow startcol endrow endcol]}
(var range {})

(lambda save-range [bufnr motion-type]
  (let [[startrow startcol endrow endcol] (get-operator-range motion-type)
        regtype (motion-type:sub 1 1)]
    (tset range bufnr [startrow startcol endrow endcol])
    (h-range bufnr namespace highlight [startrow startcol] [endrow endcol]
             {: regtype})))

(fn clear-range [bufnr]
  (nvim_buf_clear_namespace bufnr namespace 0 -1)
  (tset range bufnr nil))

(lambda swap [bufnr src-range motion-type]
  (let [[ssr ssc ser sec] src-range
        [dsr dsc der dec] (get-operator-range motion-type)
        src-content (nvim_buf_get_text bufnr ssr ssc ser sec {})
        dst-content (nvim_buf_get_text bufnr dsr dsc der dec {})
        src-text (table.concat src-content "\n")
        dst-text (table.concat dst-content "\n")
        text-edits [{:range {:start {:line ssr :character ssc}
                             :end {:line ser :character sec}}
                     :newText dst-text}
                    {:range {:start {:line dsr :character dsc}
                             :end {:line der :character dec}}
                     :newText src-text}]]
    (apply_text_edits text-edits bufnr :utf-8))
  (clear-range bufnr))

(lambda _G.swap_textobjects [motion-type]
  (let [bufnr (nvim_get_current_buf)
        src-range (. range bufnr)]
    (if src-range
        (swap bufnr src-range motion-type)
        (save-range bufnr motion-type))))

(fn setup []
  (kset :n :gs "<Cmd>set operatorfunc=v:lua.swap_textobjects<CR>g@")
  (kset :n :<Leader>sd #(clear-range (nvim_get_current_buf))
        {:desc "Clear swap source"}))

{: setup}
