local helper = require("plugins.my-luasnip.helper")

local s = helper.s
local f = helper.f

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
  s("uuidgen", f(shell, {}, "uuidgen")),
  s("date", f(shell, {}, "date --iso-8601")),
  s("datetime", f(shell, {}, "date --rfc-3339=seconds")),
  s("datetimei", f(shell, {}, "date --iso-8601=seconds")),
}

return snips
