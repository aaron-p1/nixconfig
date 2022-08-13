(local {: s : i : fmta} (require :plugins.luasnip.snippets.utils))

[(s :p (fmta "{{ <> }}" (i 0)))
 (s :pp (fmta "{!! <> !!}" (i 0)))
 (s :ph (fmta "@php\n\t<>\n@endphp" (i 0)))
 (s :pi (fmta "@if (<>)\n\t<>\n@endif" [(i 1) (i 0)]))
 (s :pf (fmta "@for (<>)\n\t<>\n@endfor" [(i 1) (i 0)]))
 (s :pfe (fmta "@foreach (<>)\n\t<>\n@endforeach" [(i 1) (i 0)]))]
