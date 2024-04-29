(local {:api {: nvim_list_wins
              : nvim_win_get_buf
              : nvim_buf_get_name
              : nvim_win_set_hl_ns
              : nvim_create_namespace
              : nvim_create_augroup
              : nvim_set_hl
              : nvim_create_autocmd}
        :cmd {: colorscheme}} vim)

(local {: setup
        :palette {: dark0
                  : dark1
                  : dark2
                  : bright_red
                  : bright_green
                  : bright_aqua
                  : bright_yellow
                  : bright_blue}} (require :gruvbox))

(local term-hl-ns (nvim_create_namespace :TerminalColors))

(lambda set-term-hl-ns []
  (let [wins (nvim_list_wins)]
    (each [_ win (ipairs wins)]
      (let [win-bufnr (nvim_win_get_buf win)
            buf-name (nvim_buf_get_name win-bufnr)]
        (if (string.match buf-name "^term://")
            (nvim_win_set_hl_ns win term-hl-ns)
            (nvim_win_set_hl_ns win 0))))))

(fn change-terminal-colors []
  (set vim.g.terminal_color_0 "#181818")
  (set vim.g.terminal_color_1 "#AC4242")
  (set vim.g.terminal_color_2 "#90A959")
  (set vim.g.terminal_color_3 "#F4BF75")
  (set vim.g.terminal_color_4 "#6A9FB5")
  (set vim.g.terminal_color_5 "#AA759F")
  (set vim.g.terminal_color_6 "#75B5AA")
  (set vim.g.terminal_color_7 "#D8D8D8")
  (set vim.g.terminal_color_8 "#6B6B6B")
  (set vim.g.terminal_color_9 "#C55555")
  (set vim.g.terminal_color_10 "#AAC474")
  (set vim.g.terminal_color_11 "#FECA88")
  (set vim.g.terminal_color_12 "#82B8C8")
  (set vim.g.terminal_color_13 "#C28CB8")
  (set vim.g.terminal_color_14 "#93D3C3")
  (set vim.g.terminal_color_15 "#F8F8F8")
  (let [group (nvim_create_augroup :TerminalColors {})]
    (nvim_set_hl term-hl-ns :Normal
                 {:fg vim.g.terminal_color_7 :bg vim.g.terminal_color_0})
    (nvim_create_autocmd [:TermOpen :TermEnter]
                         {: group :callback set-term-hl-ns})))

(fn config []
  (setup {:undercurl true
          :underline true
          :bold true
          :strikethrough true
          :invert_selection true
          :invert_signs false
          :invert_tabline false
          :invert_intend_guides false
          :inverse true
          :contrast ""
          :overrides {; spell
                      :SpellBad {:link :GruvboxYellowUnderline}
                      ; diff - reverse does not work with indentblankline
                      :DiffDelete {:bg "#9a2a2a" :fg :NONE :reverse false}
                      :DiffAdd {:bg "#284028" :fg :NONE :reverse false}
                      :DiffChange {:bg "#284848" :fg :NONE :reverse false}
                      :DiffText {:bg "#474728" :fg :NONE :reverse false}
                      ; Float
                      :NormalFloat {:bg dark1}
                      ; match-visual
                      :VisualMatch {:bg "#5c534c"}
                      ; telescope
                      :TelescopeMatching {:link :GruvboxRedBold}
                      :TelescopeSelection {:fg :NONE :bg dark2 :bold false}
                      ; dressing
                      :FloatBorder {:link :TelescopeBorder}
                      :FloatTitle {:link :TelescopeTitle}
                      ; cmp
                      :CmpItemAbbrMatch {:link :GruvboxRedBold}
                      :CmpItemAbbrMatchFuzzy {:link :GruvboxYellow}
                      ; copilot
                      :CopilotSuggestion {:fg "#00FF88" :italic true}
                      ; virt-notes
                      :VirtNote {:fg bright_blue :bg dark2}}})
  (colorscheme :gruvbox)
  (change-terminal-colors))

{: config}
