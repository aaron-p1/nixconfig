(local {:api {: nvim_list_wins
              : nvim_win_get_buf
              : nvim_buf_get_name
              : nvim_win_set_hl_ns
              : nvim_create_namespace
              : nvim_create_augroup
              : nvim_set_hl
              : nvim_create_autocmd}
        :cmd {: colorscheme}} vim)

(local {: setup} (require :gruvbox))
(local {:colors {: dark0
                 : dark2
                 : bright_red
                 : bright_green
                 : bright_aqua
                 : bright_yellow
                 : bright_blue}} (require :gruvbox.palette))

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
  (set vim.g.terminal_color_0 "#1D1F21")
  (set vim.g.terminal_color_1 "#cc6666")
  (set vim.g.terminal_color_2 "#b5bd68")
  (set vim.g.terminal_color_3 "#f0c674")
  (set vim.g.terminal_color_4 "#81a2be")
  (set vim.g.terminal_color_5 "#b294bb")
  (set vim.g.terminal_color_6 "#8abeb7")
  (set vim.g.terminal_color_7 "#c5c8c6")
  (set vim.g.terminal_color_8 "#666666")
  (set vim.g.terminal_color_9 "#d54e53")
  (set vim.g.terminal_color_10 "#b9ca4a")
  (set vim.g.terminal_color_11 "#e7c547")
  (set vim.g.terminal_color_12 "#7aa6da")
  (set vim.g.terminal_color_13 "#c397d8")
  (set vim.g.terminal_color_14 "#70c0b1")
  (set vim.g.terminal_color_15 "#eaeaea")
  (let [group (nvim_create_augroup :TerminalColors {})]
    (nvim_set_hl term-hl-ns :Normal {:fg "#c5c8c6" :bg "#1D1F21"})
    (nvim_create_autocmd :BufEnter {: group :callback set-term-hl-ns})))

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
