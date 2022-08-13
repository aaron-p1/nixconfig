(local {: startswith : endswith : tbl_extend} vim)

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

(lambda copy [table]
  (collect [key val (pairs table)]
    key
    val))

(lambda concat [list1 list2]
  (icollect [_ val (pairs list2) :into (copy list1)]
    val))

(lambda flatten [table]
  (accumulate [result [] _ v (pairs table)]
    (concat result v)))

(fn chain [...]
  (let [fnchain [...]]
    (fn [...]
      (unpack (accumulate [args [...] _ val (ipairs fnchain)]
                [(val (unpack args))])))))

;;; vim utils
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
 : copy
 : concat
 : flatten
 : chain
 :set_options set-options
 :map_keys map-keys
 :register_plugin_wk register-plugin-wk}
