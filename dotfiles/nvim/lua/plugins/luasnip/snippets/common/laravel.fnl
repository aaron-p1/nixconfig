(local {: s : sn : t : i : c : fmta} (require :plugins.luasnip.snippets.utils))

[(s :fna (fmta "/**
 * <>
 *
 * @return Attribute
 */
public function <>(): Attribute
{
\treturn Attribute::make(
\t\tget: <>
\t);
}" [(i 1) (i 2 :attribute) (i 0 :null)]))]
