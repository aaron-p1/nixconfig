(local {: s : i : t : fmta} (require :plugins.luasnip.snippets.utils))

[(s :t (t :true))
 (s :f (t :false))
 (s :if (fmta "if (<>) {\n\t<>\n}" [(i 1 :true) (i 0)]))
 (s :ei (fmta "else if (<>) {\n\t<>\n}" [(i 1 :true) (i 0)]))
 (s :el (fmta "else {\n\t<>\n}" (i 0)))
 (s :r (t :return))]
