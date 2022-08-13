(local {: s : i : fmta : conds} (require :plugins.luasnip.snippets.utils))

[(s :ed (fmta "export default <>;" (i 0)))
 (s :fn (fmta "(<>) =>> {\n\t<>\n}" [(i 1) (i 0)])
    {:condition #(not (conds.line_begin $...))})]
