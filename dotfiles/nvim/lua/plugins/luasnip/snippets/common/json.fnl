(local {: s : i : t : fmta : mc : ac} (require :plugins.luasnip.snippets.utils))

(local type-table {:t (t :true)
                   :f (t :false)
                   :n (t "")
                   :s (fmta "\"<>\"" (i 1))
                   :a (fmta "[\n\t<>\n]" (i 1))
                   :o (fmta "{\n\t<>\n}" (i 1))})

[(s :t (t :true))
 (s :f (t :false))
 (s {:trig "o([tfnsao])(c?)" :regTrig true}
    (fmta "\"<>\": <><>" [(i 1) (ac 2 1 type-table) (mc 2 ",")]))
 (s {:trig "a([tfsao])(c?)" :regTrig true}
    (fmta "<><>" [(ac 2 1 type-table) (mc 2 ",")]))]
