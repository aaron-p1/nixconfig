(local {: s : i : rep : fmta : read_template_file : o_file_start}
       (require :plugins.luasnip.snippets.utils))

[(s :initmod (fmta (read_template_file :nix-mod.nix)
                   [(rep 1) (i 1) (i 2) (i 0)] o_file_start))
 (s :init-flake-cmake (fmta (read_template_file :nix-flake-cmake.nix)
                            [(i 2 "C Project") (i 2 :Project) (i 3 :1.0)]
                            o_file_start))]
