local plugin = {}

function plugin.config()
  require("nvim-treesitter.configs").setup({
    textobjects = {
      select = {
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
          ["al"] = "@loop.outer",
          ["il"] = "@loop.inner",
          ["ac"] = "@comment.outer",
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]m"] = "@function.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>sa"] = "@parameter.inner",
          ["<leader>sf"] = "@function.outer",
        },
        swap_previous = {
          ["<leader>sA"] = "@parameter.inner",
          ["<leader>sF"] = "@function.outer",
        },
      },
    },
  })

  local helper = require("helper")

  helper.registerPluginWk({
    prefix = "<leader>",
    map = {
      s = {
        name = "Swap",
        a = "Argument forward",
        A = "Argument backward",
        f = "Function forward",
        F = "Function backward",
      },
    },
  })
end

return plugin
