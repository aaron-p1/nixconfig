local ns = vim.api.nvim_create_namespace("extraction_edit")

---add start and end extmarks to the buffer
---@param bufnr integer
---@param range integer[]
---@return integer[]
local function add_extmarks(bufnr, range)
  local start_row, start_col, end_row, end_col = unpack(range)

  local start = vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, start_col, {
    virt_text = { { "X", "Error" } },
    virt_text_pos = "overlay",
    right_gravity = false,
  })
  local end_ = vim.api.nvim_buf_set_extmark(bufnr, ns, end_row, end_col, {
    virt_text = { { "X", "Error" } },
    virt_text_pos = "overlay",
  })

  return { start, end_ }
end

---create new window
---@param bufnr integer
---@return integer
local function create_window(bufnr)
  return vim.api.nvim_open_win(bufnr, true, {
    split = "below",
    win = 0,
  })
end

---check if two tables are equal
---@param t1 table
---@param t2 table
---@return boolean
local function tbl_equal(t1, t2)
  if #t1 ~= #t2 then
    return false
  end

  for i = 1, #t1 do
    if t1[i] ~= t2[i] then
      return false
    end
  end

  return true
end

---extract range from extmarks
---@param bufnr integer
---@param start integer
---@param end_ integer
---@return integer[]
local function get_range_from_ext(bufnr, start, end_)
  local start_range = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, start, {})
  local end_range = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, end_, {})

  return { start_range[1] + 1, start_range[2], end_range[1] + 1, end_range[2] }
end

---return indented lines
---
---@param lines string[]
---@param indent string
---@return string[]
local function reindent(lines, indent)
  return vim.tbl_map(function(line)
    if line == "" then
      return line
    end

    return indent .. line
  end, lines)
end

---return deindented lines and indent
---
---only consider common whitespace prefix
---
---@param lines string[]
---@return string, string[]
local function deindent(lines)
  if #lines == 0 then
    return "", lines
  end

  local indent = lines[1]:match("^%s*")

  if indent == "" then
    return "", lines
  end

  indent = vim.iter(lines):fold(indent, function(acc, line)
    if vim.startswith(line, acc) or line == "" then
      return acc
    end

    local new_indent = line:match("^%s*")

    if not vim.startswith(acc, new_indent) then
      return ""
    end

    return new_indent
  end)

  return indent, vim.tbl_map(function(line)
    return line:sub(#indent + 1)
  end, lines)
end

---get smallest node at pos
---
---native nvim functions don't work
---@param tree TSTree
---@param pos integer[]
---@return TSNode?
local function get_node_at_pos(tree, pos)
  local node = tree:root()

  if not vim.treesitter.is_in_node_range(node, unpack(pos)) then
    return nil
  end

  while true do
    local child_count = node:named_child_count()

    local found = false

    for i = 0, child_count - 1 do
      local child = node:named_child(i)

      if child and vim.treesitter.is_in_node_range(child, unpack(pos)) then
        node = child
        found = true
        break
      end
    end

    if not found then
      return node
    end
  end
end

---get smallest nodes of all trees
---@param root_langtree any
---@param pos integer[]
---@param node TSNode?
---@return table
local function get_injection_nodes(root_langtree, pos, node)
  local range = {unpack(pos), unpack(pos)}

  if not node then
    node =  get_node_at_pos(root_langtree:tree_for_range(range), pos)

    local nodes = get_injection_nodes(root_langtree, pos, node)
    table.insert(nodes, {node = node, prev = nil, lang = root_langtree:lang()})

    return nodes
  end

  local nodes = {}

  local children = vim.tbl_values(root_langtree:children())

  for _, child in ipairs(children) do
    local ok, tree = pcall(function ()
      -- tree_for_range can throw an error if cursor between two languages
      -- e.g. in nix
      -- lua = "local a = 1";
      --                   ^
      return child:tree_for_range(range)
    end)

    if not ok or not tree then
      goto continue
    end

    local n = get_node_at_pos(tree, pos)

    if n then
      table.insert(nodes, {node = n, prev = node, lang = child:lang()})

      local child_nodes = get_injection_nodes(child, pos, n)

      for _, child_node in ipairs(child_nodes) do
        table.insert(nodes, child_node)
      end
    end

    ::continue::
  end

  return nodes
end

---fix range
---@param node TSNode
---@param bufnr integer
---@return table
local function get_injection_range(node, bufnr)
  local sibling = nil

  local start = {node:start()}
  sibling = node:prev_named_sibling()

  while sibling do
    start = {sibling:start()}
    sibling = sibling:prev_named_sibling()
  end

  local end_ = {node:end_()}
  sibling = node:next_named_sibling()

  while sibling do
    end_ = {sibling:end_()}
    sibling = sibling:next_named_sibling()
  end

  local start_line = vim.api.nvim_buf_get_lines(bufnr, start[1], start[1] + 1, false)[1]

  if start[2] == #start_line then
    start[1] = start[1] + 1
    start[2] = 0
  end

  if start_line:sub(0, start[2]):match("^%s+$") then
    start[2] = 0
  end

  local end_line = vim.api.nvim_buf_get_text(bufnr, end_[1], 0, end_[1], end_[2], {})[1]

  if vim.trim(end_line) == "" then
    end_[1] = end_[1] - 1
    end_[2] = #vim.api.nvim_buf_get_lines(bufnr, end_[1], end_[1] + 1, false)[1]
  end

  return {start[1], start[2], end_[1], end_[2]}
end

---get lang and range
---@param bufnr integer
---@param pos integer[] 0-indexed
---@return string?
---@return integer[]?
local function get_lang_and_range(bufnr, pos)
  local root_langtree = vim.treesitter.get_parser(bufnr)

  local nodes = get_injection_nodes(root_langtree, pos)

  if #nodes <= 1 then
    return
  end

  local smallest = vim.iter(nodes)
    :fold(nil, function (acc, x)
      if not acc then
        return x
      end

      if x.node:byte_length() < acc.node:byte_length() then
        return x
      end

      return acc
    end)

  if not smallest then
    return
  end

  if not smallest.prev then
    smallest.prev = smallest.node
  end

  local range = get_injection_range(smallest.prev, bufnr)

  return smallest.lang, range
end

local function edit_injection()
  local curpos = vim.api.nvim_win_get_cursor(0)
  curpos[1] = curpos[1] - 1
  local bufnr = vim.api.nvim_get_current_buf()

  local lang, injection_range = get_lang_and_range(bufnr, curpos)

  if not lang or not injection_range then
    vim.print("Not in an injection")
    return
  end

  local extmarks = add_extmarks(bufnr, injection_range)

  local ft = vim.treesitter.language.get_filetypes(lang)[1] or "plain"

  local fname = os.tmpname()
  vim.system({ "touch", fname }):wait()

  local text = vim.api.nvim_buf_get_text(bufnr, injection_range[1], injection_range[2], injection_range[3],
    injection_range[4], {})

  local last_line = nil

  if vim.trim(text[#text]) == "" then
    last_line = text[#text]
    table.remove(text)
  end

  local indent, old_text = deindent(text)

  local new_bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(new_bufnr, fname)
  vim.bo[new_bufnr].filetype = ft
  vim.api.nvim_buf_call(new_bufnr, function()
    vim.cmd.edit(fname)
  end)
  vim.bo[new_bufnr].bufhidden = "wipe"
  vim.bo[new_bufnr].swapfile = false

  vim.api.nvim_buf_set_lines(new_bufnr, 0, -1, false, old_text)
  vim.api.nvim_buf_call(new_bufnr, function()
    vim.cmd.write()
  end)

  create_window(new_bufnr)

  vim.api.nvim_create_autocmd("BufWritePost", {
    buffer = new_bufnr,
    callback = function()
      local new_text = vim.api.nvim_buf_get_lines(new_bufnr, 0, -1, false)

      if tbl_equal(new_text, old_text) then
        return old_text
      end

      local insert_range = get_range_from_ext(bufnr, extmarks[1], extmarks[2])

      local text_to_insert = reindent(new_text, indent)

      if last_line then
        table.insert(text_to_insert, last_line)
      end

      vim.api.nvim_buf_set_text(bufnr, insert_range[1] - 1, insert_range[2], insert_range[3] - 1, insert_range[4],
        text_to_insert)

      old_text = new_text
    end
  })

  vim.api.nvim_create_autocmd("WinClosed", {
    buffer = new_bufnr,
    callback = function()
      vim.api.nvim_buf_del_extmark(bufnr, ns, extmarks[1])
      vim.api.nvim_buf_del_extmark(bufnr, ns, extmarks[2])

      vim.api.nvim_buf_delete(new_bufnr, { force = true })
      vim.fn.delete(fname)
    end
  })
end


vim.keymap.set("n", "<Leader>e", edit_injection, { desc = "Edit Injection" })
