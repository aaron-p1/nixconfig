(local {: s : i : fmt : fmta} (require :plugins.luasnip.snippets.utils))

[(s :fnn (fmt "({}) => " (i 1)))
 (s :fn (fmta "function (<>) {\n\t<>\n}" [(i 1) (i 0)]))]
