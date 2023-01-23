(local {: colorscheme} vim.cmd)

(local {: setup} (require :gruvbox))
(local {: dark0
        : dark2
        : bright_red
        : bright_green
        : bright_aqua
        : bright_yellow
        : bright_blue} (require :gruvbox.palette))

(fn config []
  (setup {:undercurl true
          :underline true
          :bold true
          :italic true
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
                      :DiffDelete {:bg bright_red :fg dark0 :reverse false}
                      :DiffAdd {:bg bright_green :fg dark0 :reverse false}
                      :DiffChange {:bg bright_aqua :fg dark0 :reverse false}
                      :DiffText {:bg bright_yellow :fg dark0 :reverse false}
                      ; telescope
                      :TelescopeMatching {:link :GruvboxRedBold}
                      :TelescopeSelection {:bg dark2}
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
  (colorscheme :gruvbox))

{: config}
