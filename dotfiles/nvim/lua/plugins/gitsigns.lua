local plugin = {}

function plugin.config()
  local gs = require("gitsigns")
  local ga = require("gitsigns.actions")

  local helper = require("helper")

  gs.setup({
    on_attach = function(bufnr)
      local function buf_keymap(mode, key, fn, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, key, fn, opts)
      end

      -- Navigation
      buf_keymap("n", "[c", function()
        return vim.o.diff and "[c" or "<Cmd>Gitsigns prev_hunk<CR>"
      end, { expr = true })
      buf_keymap("n", "]c", function()
        return vim.o.diff and "]c" or "<Cmd>Gitsigns next_hunk<CR>"
      end, { expr = true })

      -- Staging
      buf_keymap("n", "<Leader>ghs", gs.stage_hunk)
      buf_keymap("v", "<Leader>ghs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end)

      -- Reset hunk
      buf_keymap("n", "<Leader>ghu", gs.undo_stage_hunk)
      buf_keymap("n", "<Leader>ghr", gs.reset_hunk)
      buf_keymap("v", "<Leader>ghr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end)
      buf_keymap("n", "<Leader>gR", gs.reset_buffer)

      -- View
      buf_keymap("n", "<Leader>ghp", gs.preview_hunk)
      buf_keymap("n", "<Leader>gbl", function()
        gs.blame_line(true)
      end)

      buf_keymap({ "o", "x" }, "ih", ga.select_hunk)

      helper.registerPluginWk({
        prefix = "<leader>",
        buffer = bufnr,
        map = {
          g = {
            name = "Git",
            R = "Reset Buffer",
            h = {
              name = "Hunk",
              s = "Stage",
              u = "Undo stage",
              r = "Reset",
              p = "Preview",
            },
            b = {
              name = "Blame",
              l = "Line",
            },
          },
        },
      })

      helper.registerPluginWk({ prefix = "[", buffer = bufnr, map = { c = "Prev Change" } })
      helper.registerPluginWk({ prefix = "]", buffer = bufnr, map = { c = "Next Change" } })
    end,
    update_debounce = 300,
  })
end

return plugin
