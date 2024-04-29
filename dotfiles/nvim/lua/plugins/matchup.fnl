(local {:setup t-setup} (require :nvim-treesitter.configs))

(fn setup []
  (set vim.g.matchup_surround_enabled 0)
  (set vim.g.matchup_matchparen_offscreen {})
  (set vim.g.matchup_transmute_enabled 1))

(fn config []
  (t-setup {:matchup {:enable true :include_match_words true}}))

{: setup : config}
