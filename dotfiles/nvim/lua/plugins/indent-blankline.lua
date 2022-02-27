local plugin = {}

function plugin.config()
  require("indent_blankline").setup({
    filetype_exclude = {
      "help",
      "packer",
    },
    -- for example, context is off by default, use this to turn it on
    use_treesitter = true,
    show_current_context = true,
    show_current_context_start = true,
  })
end

return plugin
