(local {: startswith
        : endswith
        : tbl_filter
        : tbl_extend
        : tbl_keys
        :api {: nvim_replace_termcodes
              : nvim_win_get_cursor
              : nvim_get_mode
              : nvim_buf_get_lines
              : nvim_buf_get_text
              : nvim_buf_set_text
              : nvim_buf_get_mark
              : nvim_buf_set_lines}
        :diagnostic {:get dget}
        :keymap {:set kset}
        :treesitter {: get_parser}} vim)

;;; Util functions
(lambda remove-prefix [str prefix]
  (if (and (not= "" prefix) (startswith str prefix))
      (str:sub (+ 1 (length prefix)) (length str))
      str))

(lambda remove-suffix [str suffix]
  (if (and (not= "" suffix) (endswith str suffix))
      (str:sub 1 (- (+ 1 (length suffix))))
      str))

(lambda remove-index [list index]
  (icollect [key val (ipairs list)]
    (if (not= key index) val)))

(lambda remove-from-end [list count]
  (var count (- (length list) count))
  (icollect [_ val (ipairs list) :until (= 0 count)]
    (do
      (set count (- count 1))
      val)))

(lambda range [n1 ?n2 ?step]
  (let [start (if ?n2 n1 0)
        end (if ?n2 ?n2 n1)
        step (if ?step ?step (if (> start end) -1 1))]
    (values #(if (> (* end step) (* (+ $2 step) step))
                 (+ $2 step)) end (- start step))))

(lambda ripairs [list]
  (values (fn [l index]
            (var result nil)
            (var resulti nil)
            (for [i (- index 1) 1 -1 :until (not= nil result)]
              (set result (. l i))
              (set resulti i))
            (values resulti result)) list (+ 1 (length list))))

(lambda reverse [list]
  (icollect [_ val (ripairs list)]
    val))

(lambda is-empty [table]
  (accumulate [result true _ _ (pairs table) :until (not result)]
    false))

(lambda index-of [table elem]
  (accumulate [result nil key val (pairs table) :until (not= nil result)]
    (if (= elem val) key)))

(lambda find-index [list func ?from-end]
  (let [iter (if ?from-end ripairs ipairs)]
    (accumulate [result nil key val (iter list) :until (not= nil result)]
      (if (func val) key))))

(lambda filter [table func]
  (tbl_filter func table))

(lambda any [table func]
  (accumulate [result false key val (pairs table) :until result]
    (func val key)))

(lambda copy [table]
  (collect [key val (pairs table)]
    key
    val))

(lambda concat [list1 list2]
  (icollect [_ val (ipairs list2) :into (copy list1)]
    val))

(lambda flatten [table]
  (accumulate [result [] _ v (pairs table)]
    (concat result v)))

(lambda map [table func]
  (collect [key val (pairs table)]
    (match (func val key)
      (k v) (values k v)
      v (values key v))))

(lambda flatmap [table func]
  (flatten (map table func)))

(lambda group-by [table func ?map]
  (accumulate [result {} key val (pairs table)]
    (let [new-key (func val key)
          mapped-val (if (= nil ?map) val (?map val key))
          new-val (match (. result new-key)
                    nil [mapped-val]
                    old (concat old [mapped-val]))]
      (tbl_extend :force result {new-key new-val}))))

(fn chain [...]
  (let [fnchain [...]]
    (fn [...]
      (unpack (accumulate [args [...] _ val (ipairs fnchain)]
                [(val (unpack args))])))))

;;; vim utils
(lambda replace-tc [str]
  (nvim_replace_termcodes str true true true))

(lambda set-options [opt-api opts]
  (each [key val (pairs opts)]
    (if (= :number (type key))
        (let [optval (not (startswith val :no))
              optname (remove-prefix val :no)]
          (tset opt-api optname optval))
        (tset opt-api key val))))

(lambda map-keys [get-keys-fn bufnr ...]
  (each [_ map (ipairs (get-keys-fn bufnr ...))]
    (let [[mode key cmd opts] map]
      (kset mode key cmd (tbl_extend :force opts {:buffer bufnr})))))

(lambda get-operator-range [motion-type]
  "Get 0-indexed range of operator motion"
  (let [charwise? (= motion-type :char)
        [start-mark-row start-mark-col] (nvim_buf_get_mark 0 "[")
        [end-mark-row end-mark-col] (nvim_buf_get_mark 0 "]")
        start-row (- start-mark-row 1)
        end-row (- end-mark-row 1)]
    (if charwise? [start-row start-mark-col end-row (+ 1 end-mark-col)]
        (let [[end-line] (nvim_buf_get_lines 0 end-row (+ end-row 1) false)
              end-line-length (length end-line)]
          [start-row 0 end-row end-line-length]))))

(lambda get-cursor-lang []
  (let [[row col] (nvim_win_get_cursor 0)
        real-row (- row 1)
        cursor-pos [real-row col real-row col]
        (parser-found? parser) (pcall get_parser 0)]
    (if parser-found?
        (: (parser:language_for_range cursor-pos) :lang)
        nil)))

(lambda in-mode? [mode]
  (let [{:mode cur-mode} (nvim_get_mode)]
    (= mode cur-mode)))

(lambda replace-when-diag [bufnr diag-match line-match replacement]
  "Replace first nonempty line before diag when diagnostic matches diag-match"
  (let [diags (dget bufnr)
        max-prev-lines 5]
    (each [_ diag (ipairs (filter diags #(string.match $1.message diag-match)))]
      (let [row diag.lnum
            col diag.col
            [until-col] (nvim_buf_get_text bufnr row 0 row col {})]
        (if (not (until-col:match "^%s*$"))
            (let [new-line (string.gsub until-col line-match replacement)]
              (nvim_buf_set_text bufnr row 0 row col [new-line]))
            (let [start-line (math.max 0 (- row max-prev-lines))
                  lines (nvim_buf_get_lines bufnr start-line row false)
                  to-edit (find-index lines #(not ($1:match "^%s*$")) true)]
              (when (not= nil to-edit)
                (let [new-line (string.gsub (. lines to-edit) line-match
                                            replacement)
                      line-num (+ start-line to-edit -1)]
                  (nvim_buf_set_lines bufnr line-num (+ line-num 1) false
                                      [new-line])))))))))

;;; plugin utils
(lambda register-plugin-wk [config]
  (local wk (require :which-key))
  (wk.register config.map {:prefix (or config.prefix "") :buffer config.buffer}))

{:remove_prefix remove-prefix
 :remove_suffix remove-suffix
 :remove_index remove-index
 :remove_from_end remove-from-end
 : range
 : ripairs
 : reverse
 :is_empty is-empty
 :index_of index-of
 : find-index
 : filter
 : any
 : copy
 : concat
 : flatten
 : map
 : flatmap
 :group_by group-by
 : chain
 :replace_tc replace-tc
 :set_options set-options
 :map_keys map-keys
 : get-operator-range
 :get_cursor_lang get-cursor-lang
 : in-mode?
 : replace-when-diag
 :register_plugin_wk register-plugin-wk}
