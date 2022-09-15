(local {: startswith
        : tbl_filter
        : tbl_map
        :api {: nvim_create_namespace
              : nvim_get_hl_id_by_name
              : nvim_buf_get_lines
              : nvim_buf_get_extmarks
              : nvim_buf_set_extmark
              : nvim_buf_del_extmark
              : nvim_create_augroup
              : nvim_create_autocmd
              : nvim_get_current_buf}} vim)

(local default-url "https://github.com/")
(local line-pattern "^%s*%(u ")
(local plug-name-pattern "^[^:]*:([^ %)]+)")

(local namespace (nvim_create_namespace :PluginLinks))
(local comment-highlight (nvim_get_hl_id_by_name :Comment))

(fn create-extmark [bufnr id line plugin column]
  (let [plugin-link (if (startswith plugin :http) plugin
                        (.. default-url plugin))]
    (nvim_buf_set_extmark bufnr namespace (- line 1) 0
                          {: id
                           :virt_text [[plugin-link comment-highlight]]
                           :virt_text_win_col column})))

(fn get-plugin-lines [bufnr]
  (let [lines (icollect [k line (ipairs (nvim_buf_get_lines bufnr 0 -1 false))]
                [k line])]
    (->> lines
         (tbl_filter #(not= (string.match (. $1 2) line-pattern) nil))
         (tbl_map #(let [[num line] $1]
                     [num (string.match line plug-name-pattern) (length line)]))
         (tbl_filter #(not= (. $1 2) nil)))))

(fn update-extmarks [bufnr]
  (let [plugin-lines (get-plugin-lines bufnr)
        line-count (length plugin-lines)
        max-line-length (accumulate [max 0 _ line (ipairs plugin-lines)]
                          (math.max max (. line 3)))
        prev-extmark-count (length (nvim_buf_get_extmarks bufnr namespace 0 -1
                                                          {}))]
    (for [id (+ line-count 1) prev-extmark-count 1]
      (nvim_buf_del_extmark bufnr namespace id))
    (each [id line (ipairs plugin-lines)]
      (create-extmark bufnr id (. line 1) (. line 2) (+ max-line-length 2)))))

(fn setup []
  (let [augroup (nvim_create_augroup :PluginLinks {:clear true})]
    (nvim_create_autocmd [:BufRead :TextChanged :TextChangedI]
                         {:group augroup
                          :pattern :init.fnl
                          :callback #(update-extmarks (nvim_get_current_buf))})))

{: setup}
