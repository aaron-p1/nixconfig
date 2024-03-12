local M = {}

local keys = { "t", "T", "f", "F" }
local modes = { "n", "x", "o" }

M.namespace = vim.api.nvim_create_namespace("fhighlight")
M.hl = {
  graph = "FHighlightGraph",
  blank = "FHighlightBlank",
}

vim.api.nvim_set_hl(0, M.hl.graph, { fg = "#ff0000", bold = true, default = true })
vim.api.nvim_set_hl(0, M.hl.blank, { bg = "#ff0000", default = true })

--- Get start byte of character
--- @param str string
--- @param pos integer byte index of char
--- @return integer start_index starting byte index of char
local function get_char_start(str, pos)
  return pos + vim.str_utf_start(str, pos)
end

--- Get end byte of character
--- @param str string
--- @param pos integer byte index of char
--- @return integer end_index ending byte index of char
local function get_char_end(str, pos)
  return pos + vim.str_utf_end(str, pos)
end

--- @class CharPosition
--- @field col integer
--- @field blank boolean

--- Get columns of unique chars
---
--- @param line string
--- @param start_byte integer
--- @param backwards boolean
--- @param count integer nth unique char
--- @return table<string, CharPosition>
local function get_unique_chars(line, start_byte, backwards, count)
  local unique_chars = {}

  if line == "" then
    return unique_chars
  end

  start_byte = start_byte + 1

  local i = backwards and get_char_start(line, start_byte) - 1 or get_char_end(line, start_byte) + 1

  while i >= 1 and i <= #line do
    local char_start = get_char_start(line, i)
    local char_end = get_char_end(line, i)

    local char = line:sub(char_start, char_end)
    local new_count = unique_chars[char] and unique_chars[char].count + 1 or 1

    if new_count <= count then
      local is_whitespace = string.match(char, "%s") ~= nil

      unique_chars[char] = { count = new_count, info = { col = char_start - 1, blank = is_whitespace } }
    end

    i = backwards and char_start - 1 or char_end + 1
  end

  return vim.iter(unique_chars)
      :filter(function(_, v)
        return v.count == count
      end)
      :map(function(k, v)
        return unpack({ k, v.info })
      end)
      :fold({}, function(acc, k, v)
        acc[k] = v
        return acc
      end)
end

--- Highlight first unique character depending on cursor position and type
---
--- @param type string one of t, T, f, F
--- @return string
local function highlight(type)
  local backwards = type == "T" or type == "F"
  local count = vim.v.count1

  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1

  local text = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]

  local unique_chars = get_unique_chars(text, cursor[2], backwards, count)

  vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)

  -- create extmarks
  for _, info in pairs(unique_chars) do
    local hl = info.blank and M.hl.blank or M.hl.graph

    pcall(vim.api.nvim_buf_set_extmark, 0, M.namespace, line, info.col, {
      end_col = info.col + 1,
      hl_group = hl,
      priority = 9999,
    })
  end

  vim.cmd.redraw()

  local jump_char = vim.fn.nr2char(vim.fn.getchar())

  vim.api.nvim_buf_clear_namespace(0, M.namespace, 0, -1)

  return type .. jump_char
end

function M.setup()
  for _, key in ipairs(keys) do
    vim.keymap.set(
      modes,
      key,
      function()
        return highlight(key)
      end,
      { noremap = true, expr = true }
    )
  end
end

return M
