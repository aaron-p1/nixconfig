(local {:api {: nvim_buf_get_text : nvim_buf_set_text} :keymap {:set kset}} vim)

(local {: get-operator-range} (require :helper))

;; [startrow startcol endrow endcol]
(var range nil)

(lambda save-range [motion-type]
  (set range (get-operator-range motion-type)))

(lambda swap [motion-type]
  (let [[ssr ssc ser sec] range
        [dsr dsc der dec] (get-operator-range motion-type)
        src-content (nvim_buf_get_text 0 ssr ssc ser sec {})
        dst-content (nvim_buf_get_text 0 dsr dsc der dec {})]
    (if (< ssr dsr)
        (do
          (nvim_buf_set_text 0 dsr dsc der dec src-content)
          (nvim_buf_set_text 0 ssr ssc ser sec dst-content))
        (do
          (nvim_buf_set_text 0 ssr ssc ser sec dst-content)
          (nvim_buf_set_text 0 dsr dsc der dec src-content))))
  (set range nil))

(lambda _G.swap_textobjects [motion-type]
  (if range
      (swap motion-type)
      (save-range motion-type)))

(fn setup []
  (kset :n :gs "<Cmd>set operatorfunc=v:lua.swap_textobjects<CR>g@")
  (kset :n :gS #(set range nil)))

{: setup}
