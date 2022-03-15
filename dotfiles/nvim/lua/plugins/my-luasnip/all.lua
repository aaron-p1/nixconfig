local lsh = require("plugins.my-luasnip.helper")

local s = lsh.s
local f = lsh.f

-- Make sure to not pass an invalid command, as io.popen() may write over nvim-text.
local function shell(_, _, command)
  local file = io.popen(command, "r")
  local res = {}
  for line in file:lines() do
    table.insert(res, line)
  end
  return res
end

local snips = {
  s("uuidgen", f(shell, {}, { user_args = { "uuidgen" } })),
  s("date", f(shell, {}, { user_args = { "date --iso-8601" } })),
  s("datetime", f(shell, {}, { user_args = { "date --rfc-3339=seconds" } })),
  s("datetimei", f(shell, {}, { user_args = { "date --iso-8601=seconds" } })),
}

return snips
