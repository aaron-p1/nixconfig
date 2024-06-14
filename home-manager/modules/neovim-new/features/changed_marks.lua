local function set_mark()
  local mark_name = vim.fn.nr2char(vim.fn.getchar())

  return "m" .. mark_name:upper()
end

local function go_to_mark(prev_keys)
  prev_keys = prev_keys or ""

  -- Get the mark name
  local mark_name = vim.fn.nr2char(vim.fn.getchar()):upper()

  local mark_action_keys = prev_keys .. mark_name

  -- Get the mark
  local mark = vim.api.nvim_get_mark(mark_name, {})

  -- Check if mark exists
  if mark[1] == 0 and mark[2] == 0 and mark[3] == 0 and mark[4] == "" then
    vim.api.nvim_feedkeys(mark_action_keys, "n", true)
    return
  end

  local bufnr = mark[3]

  -- If the buffer number is the current buffer, feed the keys and return
  if bufnr == vim.api.nvim_get_current_buf() then
    vim.api.nvim_feedkeys(mark_action_keys, "n", true)
    return
  end

  local win = vim.fn.win_findbuf(bufnr)[1]

  -- If there's no window, create a new tab, feed the keys, delete the old buffer and return
  if not win then
    vim.cmd.tabnew()
    local old_bufnr = vim.api.nvim_get_current_buf()
    print(old_bufnr)

    vim.api.nvim_feedkeys(mark_action_keys, "n", true)

    vim.schedule(function()
      vim.api.nvim_buf_delete(old_bufnr, { force = true })
    end)

    return
  end

  -- If there's a window, set it as the current window and feed the keys
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_feedkeys(mark_action_keys, "n", true)
end

vim.keymap.set("n", "m", set_mark, { expr = true, desc = "Set mark" })
vim.keymap.set("n", "'", function() go_to_mark("'") end, { desc = "Jump to mark" })
