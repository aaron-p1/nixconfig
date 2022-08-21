(local {: line : stdpath : join : readfile} vim.fn)

(local {:snippet s
        :snippet_node sn
        :indent_snippet_node isn
        :text_node t
        :insert_node i
        :function_node f
        :choice_node c
        :dynamic_node d
        :restore_node r
        &as ls} (require :luasnip))

(local {:lambda l : rep :partial p :match m :nonempty n :dynamic_lambda dl}
       (require :luasnip.extras))

(local {: postfix} (require :luasnip.extras.postfix))
(local {: fmt : fmta} (require :luasnip.extras.fmt))

(local events (require :luasnip.util.events))
(local absolute_indexer (require :luasnip.nodes.absolute_indexer))
(local conds (require :luasnip.extras.expand_conditions))

;;;;; Util functions
;;;; Nodes
;;; match capture
(lambda mc [group then ?else]
  "Matches regex capture group in snippet"
  (f (fn [_ snip]
       (let [cap (. snip.captures group)
             valid-else (match ?else
                          nil ""
                          e e)]
         (if (and (not= nil cap) (not= "" cap)) then valid-else)))))

;;; apply capture
;;  types = [ "capture" = nodes ]
(lambda ac [pos group types]
  "Selects node inside types depending on capture group"
  (d pos #(sn nil (. types (. $2.captures group)))))

;;;; Conditions
(fn first-line []
  (= 1 (line ".")))

(lambda first-in-line [line-to-cursor matched-trigger]
  (and (first-line) (= line-to-cursor matched-trigger)))

;;;; Snippet construction functions
;;; Snip
(lambda read-template-file [name]
  (let [path (.. (stdpath :config)
                 :/lua/plugins/luasnip/snippets/file-templates/files)
        filename (.. path "/" name)]
    (join (readfile filename) "\n")))

;;;; Opts
(local o-file-start {:condition first-in-line :show_condition first-line})

{: ls
 : conds
 : events
 : s
 : sn
 : isn
 : t
 : i
 : f
 : c
 : d
 : r
 : l
 : rep
 : p
 : m
 : n
 : dl
 :pf postfix
 : fmt
 : fmta
 ; ai
 :ai absolute_indexer
 : mc
 : ac
 :first_line first-line
 :first_in_line first-in-line
 :read_template_file read-template-file
 :o_file_start o-file-start}
