local cmp = require('cmp')

-- (local cmp-sources
--        [{:name :nmp}
--         {:name :orgmode}
--         {:name :nvim_lsp :max_item_count 64}
--         {:name :luasnip}
--         {:name :path :options {:fd_timeout_msec 1000 :fd_cmd [:fd :-d :4 :-p]}}
--         {:name :calc}
--         {:name :digraphs :max_item_count 32}
--         {:name :buffer :option {:get_bufnrs #(nvim_list_bufs)}}])

cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "path",   options = { fd_timeout_msec = 1000, fd_cmd = { "fd", "-d", "4", "-p" } } },
    { name = "calc" },
    { name = "buffer", option = { get_bufnrs = function() return vim.api.nvim_list_bufs() end } },
  },
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<M-e>"] = cmp.mapping.close(),
    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
    ["<C-d>"] = cmp.mapping.scroll_docs(4),
    ["<C-n>"] = cmp.mapping(
      cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert, select = true }),
      { "i", "c" }
    ),
    ["<C-p>"] = cmp.mapping(
      cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert, select = true }),
      { "i", "c" }
    ),
  },
  preselect = cmp.PreselectMode.Item,
  experimental = {
    ghost_text = true,
  },
})

vim.g.copilot_no_maps = true
vim.g.copilot_filetypes = { TelescopePrompt = false, DressingInput = false }

vim.keymap.set("i", "<C-o>", 'copilot#Accept("")', { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<C-S-o>", 'copilot#AcceptLine()', { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<M-o>", 'copilot#AcceptWord()', { expr = true, replace_keycodes = false })
vim.keymap.set("i", "<M-[>", "<Cmd>call copilot#Previous()<CR>", { silent = true })
vim.keymap.set("i", "<M-]>", "<Cmd>call copilot#Next()<CR>", { silent = true })

return {
  lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
}
