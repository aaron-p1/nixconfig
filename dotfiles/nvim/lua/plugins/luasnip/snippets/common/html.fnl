(local {: concat} (require :helper))

(local {: s : i : l : fmt} (require :plugins.luasnip.snippets.utils))

(local snip-shorts {:repeat-tag #(l (l._1:match "^[^ ]*") $1)})

(local attributes {:i :id
                   :cl :class
                   :h :href
                   :t :type
                   :n :name
                   :m :method
                   :v :value})

(local attribute-snips
       (icollect [trig attr (pairs attributes)]
         (s (.. :a trig) (fmt (.. attr "=\"{}\"") (i 1)))))

(local snips
       [(s "<"
           (fmt "<{}>\n\t{}\n</{}>"
                [(i 1 :div) (i 2) (snip-shorts.repeat-tag 1)]))
        (s :<i
           (fmt "<{}>{}</{}>" [(i 1 :div) (i 2) (snip-shorts.repeat-tag 1)]))
        (s {:trig "=" :wordTrig false} (fmt "=\"{}\"" (i 1)))
        (s :itext (fmt "<input type=\"text\"{}/>" (i 1)))
        (s :inumber (fmt "<input type=\"number\"{}/>" (i 1)))])

(concat snips attribute-snips)
