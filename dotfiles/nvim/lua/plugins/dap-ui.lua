local kset = vim.keymap.set

local wk_register = require("plugins.which-key").register

local M = {}

function M.config()
  local dapui = require("dapui")

  dapui.setup({
    controls = { enabled = false },
    element_mappings = {},
    expand_lines = true,
    floating = {
      border = "single",
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    force_buffers = true,
    icons = {
      collapsed = "",
      current_frame = "",
      expanded = "",
    },
    layouts = {
      {
        elements = {
          {
            id = "scopes",
            size = 0.45,
          },
          {
            id = "watches",
            size = 0.25,
          },
          {
            id = "breakpoints",
            size = 0.10,
          },
          {
            id = "stacks",
            size = 0.20,
          },
        },
        position = "left",
        size = 60,
      },
      {
        elements = {
          {
            id = "repl",
            size = 0.5,
          },
          {
            id = "console",
            size = 0.5,
          },
        },
        position = "bottom",
        size = 20,
      },
    },
    mappings = {
      edit = "e",
      expand = { "<CR>" },
      open = "o",
      remove = "d",
      repl = "r",
      toggle = "t",
    },
    render = {
      indent = 1,
      max_value_lines = 100,
    },
  })

  kset("n", "<Leader>dd", dapui.toggle, { desc = "Toggle dap UI" })
  kset({ "n", "v" }, "<Leader>de", dapui.eval, { desc = "Evaluate expression" })

  wk_register({ prefix = "<Leader>", map = { d = { name = "dap" } } })
end

return M
