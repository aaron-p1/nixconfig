(local {: s : i : t : fmta : c} (require :plugins.luasnip.snippets.utils))

[(s :glob (fmta "file(GLOB <> <>))" [(i 1 :Sources) (i 2 :*.cpp)]))
 (s :cstd (fmta "set(CMAKE_C_STANDARD <>)" [(c 1 [(t :11) (t :99)])]))
 (s :cppstd (fmta "set(CMAKE_CXX_STANDARD <>)"
                  [(c 1 [(t :17) (t :14) (t :11)])]))
 (s :compilecmd (t "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)"))]
