local kset = vim.keymap.set

local dap = require("dap")

local M = {}

--- Call function cb
--- @param fn function
--- @param ... any
--- @return function
local function call(fn, ...)
  local args = { ... }

  return function()
    fn(unpack(args))
  end
end

function M.config()
  kset("n", "<F1>", call(dap.repl.toggle))
  kset("n", "<F2>", call(dap.step_over))
  kset("n", "<F3>", call(dap.step_into))
  kset("n", "<F4>", call(dap.step_out))

  kset("n", "<F5>", call(dap.continue))
  kset("n", "<F6>", call(dap.disconnect))
  kset("n", "<F7>", call(dap.run_to_cursor))
  kset("n", "<F8>", call(dap.toggle_breakpoint))
  kset("n", "<Leader><F8>", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end)
  kset("n", "<F9>", call(dap.list_breakpoints))
  kset("n", "<F10>", call(dap.up))
  kset("n", "<Leader><F10>", call(dap.down), { desc = "Stack down" })

  dap.adapters.php = {
    type = "executable",
    port = 9003,
    command = "@nodejs_16@/bin/node",
    args = { "@phpDebugJs@" },
  }

  dap.configurations.php = {
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug",
      serverSourceRoot = "/var/www",
      localSourceRoot = vim.fn.getcwd(),
    },
  }
end

return M
