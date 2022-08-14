(fn config []
  (local g (require :gruvbox))
  (local colors (require :gruvbox.palette))
  (g.setup {:undercurl true
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
            :overrides {; telescope
                        :TelescopeMatching {:link :GruvboxRedBold}
                        :TelescopeSelection {:bg colors.dark2}
                        ; dressing
                        :FloatBorder {:link :TelescopeBorder}
                        :FloatTitle {:link :TelescopeTitle}
                        ; cmp
                        :CmpItemAbbrMatch {:link :GruvboxRedBold}
                        :CmpItemAbbrMatchFuzzy {:link :GruvboxYellow}
                        ; copilot
                        :CopilotSuggestion {:fg "#00FF88" :italic true}
                        ; virt-notes
                        :VirtNote {:fg colors.bright_blue :bg colors.dark2}}})
  (vim.cmd "colorscheme gruvbox"))

{: config}
