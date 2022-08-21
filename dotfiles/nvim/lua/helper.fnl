(local {: startswith : endswith : tbl_filter : tbl_extend} vim)
(local {: nvim_replace_termcodes} vim.api)

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

(lambda index-of [table elem]
  (accumulate [result nil key val (pairs table) :until (not= nil result)]
    (if (= elem val) key)))

(lambda filter [table func]
  (tbl_filter func table))

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
      (vim.keymap.set mode key cmd (tbl_extend :force opts {:buffer bufnr})))))

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
 :index_of index-of
 : filter
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
 :register_plugin_wk register-plugin-wk}
