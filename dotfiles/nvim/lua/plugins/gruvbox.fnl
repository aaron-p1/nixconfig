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
            :overrides {:TelescopeMatching {:link :GruvboxRedBold}
                        :TelescopeSelection {:bg colors.dark2}
                        :CmpItemAbbrMatch {:link :GruvboxRedBold}
                        :CmpItemAbbrMatchFuzzy {:link :GruvboxYellow}
                        :CopilotSuggestion {:fg "#00FF88" :italic true}}})
  (vim.cmd "colorscheme gruvbox"))

{: config}
