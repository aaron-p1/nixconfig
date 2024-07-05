local namespace = vim.api.nvim_create_namespace("SwapTextobjects")
local highlight = "IncSearch"

-- {[bufnr] = {startrow startcol endrow endcol}}
local range = {}

---save and highlight range
---@param bufnr integer
---@param motion_type string
local function save_range(bufnr, motion_type)
  local startrow, startcol, endrow, endcol = unpack(Configs.utils.get_operator_range(motion_type))
  local regtype = motion_type:sub(1, 1)

  range[bufnr] = { startrow, startcol, endrow, endcol }

  vim.highlight.range(bufnr, namespace, highlight, { startrow, startcol }, { endrow, endcol }, { regtype = regtype })
end

---clear range
---@param bufnr integer
local function clear_range(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

  range[bufnr] = nil
end

---swap textobjects
---@param bufnr integer
---@param src_range table
---@param motion_type string
local function swap(bufnr, src_range, motion_type)
  local ssr, ssc, ser, sec = unpack(src_range)
  local dsr, dsc, der, dec = unpack(Configs.utils.get_operator_range(motion_type))
  local src_content = vim.api.nvim_buf_get_text(bufnr, ssr, ssc, ser, sec, {})
  local dst_content = vim.api.nvim_buf_get_text(bufnr, dsr, dsc, der, dec, {})
  local src_text = table.concat(src_content, "\n")
  local dst_text = table.concat(dst_content, "\n")

  local text_edits = {
    {
      range = {
        start = { line = ssr, character = ssc },
        ["end"] = { line = ser, character = sec }
      },
      newText = dst_text
    },
    {
      range = {
        start = { line = dsr, character = dsc },
        ["end"] = { line = der, character = dec }
      },
      newText = src_text
    }
  }

  vim.lsp.util.apply_text_edits(text_edits, bufnr, "utf-8")

  clear_range(bufnr)
end

---swap textobjects
---@param motion_type string
function Swap_textobjects(motion_type)
  local bufnr = vim.api.nvim_get_current_buf()
  local src_range = range[bufnr]

  if src_range then
    swap(bufnr, src_range, motion_type)
  else
    save_range(bufnr, motion_type)
  end
end

vim.keymap.set({ "n", "v" }, "gs", "<Cmd>set operatorfunc=v:lua.Swap_textobjects<CR>g@")
vim.keymap.set("n", "<Leader>S", function()
  clear_range(vim.api.nvim_get_current_buf())
end, { desc = "Clear swap source" })
