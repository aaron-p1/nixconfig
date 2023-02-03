(local {: uri_from_bufnr
        :api {: nvim_create_namespace
              : nvim_buf_get_lines
              : nvim_buf_clear_namespace
              : nvim_buf_set_extmark}
        :lsp {: buf_request_all}
        :treesitter {: parse_query : get_parser}} vim)

(local queries {:php "(assignment_expression (variable_name) @assignment)"})

(local namespace (nvim_create_namespace :ShowTypes))

(lambda create-extmark-from-hover-result [bufnr results]
  (each [_ result (pairs results)]
    (let [content (?. result :result :contents :value)
          start (?. result :result :range :start)
          line (?. start :line)
          current-lines (if line
                            (nvim_buf_get_lines bufnr line (+ line 1) false))
          [current-line] (or current-lines [])
          col (if current-line (- (or (string.find current-line "%S") 0) 1))
          var-type (if content (string.match content "@.*`(.*) %$"))
          short-type (if var-type (< (length var-type) col))
          mark-col (if short-type (- col 1 (length var-type)) 0)]
      (when var-type
        (nvim_buf_clear_namespace bufnr namespace line (+ line 1))
        (nvim_buf_set_extmark bufnr namespace line mark-col
                              {:virt_text [[var-type :Comment]]
                               :virt_text_pos (if short-type :overlay :eol)
                               :hl_mode :combine})))))

(lambda get-hover [bufnr row col]
  (buf_request_all bufnr :textDocument/hover
                   {:textDocument {:uri (uri_from_bufnr bufnr)}
                    :position {:line row :character col}}
                   (partial create-extmark-from-hover-result bufnr)))

(lambda each-match [query root-node bufnr]
  (each [_ node (query:iter_captures root-node bufnr 0 -1)]
    (let [(row col) (node:start)]
      (when (> col 1)
        (pcall get-hover bufnr row col)))))

;; fnlfmt: skip
(fn show-types [bufnr lang]
  (nvim_buf_clear_namespace bufnr namespace 0 -1)
  (let [query (parse_query lang (. queries lang))]
    (match-try (get_parser bufnr lang)
      parser (parser:parse)
      [lang-tree] (lang-tree:root)
      root-node (each-match query root-node bufnr))))

{: show-types}
