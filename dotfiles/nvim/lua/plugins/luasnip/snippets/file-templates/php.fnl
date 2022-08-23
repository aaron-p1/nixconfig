(local {: tbl_map : split : endswith : startswith} vim)

(local {: fnamemodify : readfile : expand} vim.fn)

(local fs vim.fs)

(local {: s : sn : i : t : d : fmta : read_template_file : o_file_start}
       (require :plugins.luasnip.snippets.utils))

(lambda path->namespace [path]
  (if (= path ".") nil
      (let [namespace-sections (tbl_map #(string.gsub $1 "^%l" string.upper)
                                        (split path "/"))]
        (accumulate [ns nil _ section (ipairs namespace-sections)]
          (if (= nil ns) section (.. ns "\\" section))))))

(lambda get-sibling-php-file [file]
  "Takes file path and returns file path"
  (let [path (fnamemodify file ":h")
        fname (fnamemodify file ":t")]
    (accumulate [f nil n t (fs.dir path) :until (not= nil f)]
      (if (and (endswith n :.php) (= t :file) (not= fname n))
          (.. path "/" n)))))

(lambda sibling->namespace [file]
  (let [rfile (get-sibling-php-file file)]
    (if (= nil rfile) nil
        (accumulate [ns nil _ l (ipairs (readfile rfile "" 5)) :until (not= nil
                                                                            ns)]
          (if (startswith l :namespace)
              (l:match "%w+ (.+);"))))))

(lambda namespace->snip [namespace]
  (sn nil [(t ["" "namespace "]) (i 1 namespace) (t [";" ""])]))

(fn get-namespace-snip []
  (let [file (expand "%:.:h")
        namespace (match (sibling->namespace file)
                    nil (path->namespace file)
                    ns ns)]
    (if (= nil namespace) (sn nil (t "")) (namespace->snip namespace))))

(fn get-class-name-snip []
  (sn nil (i 1 (expand "%:t:r"))))

[(s :initclass (fmta (read_template_file :php-class.php)
                     [(d 1 get-namespace-snip [])
                      (d 2 get-class-name-snip [])
                      (i 3)
                      (i 0)]) o_file_start)]
