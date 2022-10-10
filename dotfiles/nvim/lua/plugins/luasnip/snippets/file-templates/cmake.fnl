(local {: s : i : c : fmta : sn : rep : ai : read_template_file : o_file_start}
       (require :plugins.luasnip.snippets.utils))

[(s :initroot (fmta (read_template_file :cmake-root.cmake)
                    [(i 1 :ProjectName)
                     (c 2 [(sn nil
                               (fmta "add_executable(<> <>)"
                                     [(rep (. ai 1)) (i 1 :src/main.cpp)]))
                           (sn nil
                               (fmta "file(GLOB <> <>)\nadd_executable(<> ${<>})"
                                     [(i 1 :Sources)
                                      (i 2 :src/*.cpp)
                                      (rep (. ai 1))
                                      (rep 1)]))])]
                    o_file_start))]
