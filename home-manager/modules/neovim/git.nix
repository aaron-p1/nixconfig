{ pkgs, ... }: {
  name = "git";
  plugins = with pkgs.vimPlugins; [
    vim-fugitive
    vim-rhubarb
    gitsigns-nvim
    diffview-nvim
  ];
  config = # lua
    ''
      vim.keymap.set({ "n", "v" }, "<Leader>go", ":GBrowse<CR>", { silent = true, desc = "Open in browser" })
      vim.keymap.set("n", "<Leader>gbb", "<Cmd>Git blame<CR>", { silent = true, desc = "Whole file" })
      vim.keymap.set("n", "<Leader>gcc", "<Cmd>Gvsplit @:%<CR>", { silent = true, desc = "Open before changes" })

      local group = vim.api.nvim_create_augroup("FugitiveConfig", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "fugitive",
        callback = function(ev)
          vim.keymap.set("n", "R", vim.fn["fugitive#ReloadStatus"], { buffer = ev.buf })
        end
      })

      local old_msg = {}

      local function put_commit_msg()
        if #old_msg > 0 then
          vim.api.nvim_buf_set_lines(0, 0, 1, true, old_msg)
        end
      end

      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "FugitiveEditor",
        callback = function()
          local msg_start = old_msg[1] and old_msg[1]:sub(1, 10)

          if vim.g.fugitive_result.args[1] == "commit" and msg_start then
            vim.keymap.set("n", "<Leader>gp", put_commit_msg, { buffer = true, desc = "Paste " .. msg_start })
          end
        end
      })

      vim.api.nvim_create_autocmd("BufWrite", {
        group = group,
        pattern = "COMMIT_EDITMSG",
        callback = function(ev)
          old_msg = vim.iter(vim.api.nvim_buf_get_lines(ev.buf, 0, -1, true))
              :filter(function(line) return not line:find("^#") end)
              :totable()
        end
      })

      vim.api.nvim_create_autocmd("BufRead", {
        group = group,
        pattern = "fugitive://*",
        callback = function()
          vim.keymap.set("n", "<Leader>ge", "<Cmd>Gtabedit<CR>",
            { buffer = true, silent = true, desc = "Open in working tree" })
        end
      })

      local gs = require("gitsigns")

      local function gs_attach(bufnr)
        if vim.api.nvim_buf_get_name(bufnr):match("secrets") then
          return false
        end

        local function kset(mode, key, rhs, opts)
          vim.keymap.set(mode, key, rhs, vim.tbl_extend("force", { buffer = bufnr }, opts))
        end

        kset("n", "[c", function()
          return vim.o.diff and "[c" or "<Cmd>Gitsigns prev_hunk<CR>"
        end, { expr = true, desc = "Prev hunk" })
        kset("n", "]c", function()
          return vim.o.diff and "]c" or "<Cmd>Gitsigns next_hunk<CR>"
        end, { expr = true, desc = "Next hunk" })

        kset("n", "<Leader>ghr", gs.reset_hunk, { desc = "Reset" })
        kset("n", "<Leader>ghR", gs.reset_buffer, { desc = "Reset buffer" })

        kset("n", "<Leader>ghp", gs.preview_hunk, { desc = "Preview" })
        kset("n", "<Leader>gbl", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })

        local gsa = require("gitsigns.actions")
        kset({ "o", "x" }, "ih", gsa.select_hunk, { desc = "In hunk" })

        Configs.which_key.add({
          { "g",  group = "Git" },
          { "gh", group = "Hunk" },
          { "gb", group = "Blame" },
        }, { "<Leader>", buffer = bufnr })
      end

      gs.setup({
        update_debounce = 300,
        diff_opts = { linematch = 60 },
        on_attach = gs_attach,
      })

      local dv = require("diffview")
      local dva = require("diffview.actions")

      dv.setup({
        file_panel = { win_config = { position = "right" } },
        keymaps = {
          disable_defaults = true,
          view = { ["<Tab>"] = dva.select_next_entry, ["<S-Tab>"] = dva.select_prev_entry },
          file_panel = {
            ["<CR>"] = dva.focus_entry,
            ["<Tab>"] = dva.select_next_entry,
            ["<S-Tab>"] = dva.select_prev_entry,
            i = dva.listing_style,
            R = dva.refresh_files,
          },
          file_history_panel = {
            ["<CR>"] = dva.select_entry,
            ["g!"] = dva.options,
            L = dva.open_commit_log,
            ["<Tab>"] = dva.select_next_entry,
            ["<S-Tab>"] = dva.select_prev_entry,
            gf = dva.goto_file_tab,
            gy = dva.copy_hash,
          },
          option_panel = { ["<Tab>"] = dva.select_entry, q = dva.close },
        },
        hooks = { diff_buf_read = function() vim.opt_local.wrap = false end },
      })

      function _G.Diffview_file_history()
        local start_line = vim.api.nvim_buf_get_mark(0, "[")[1]
        local end_line = vim.api.nvim_buf_get_mark(0, "]")[1]
        dv.file_history({ start_line, end_line })
      end

      vim.keymap.set("n", "<Leader>gdf", "<Cmd>DiffviewFileHistory %<CR>", { silent = true, desc = "Current file history" })
      vim.keymap.set({ "n", "v" }, "<Leader>gdF", "<Cmd>DiffviewFileHistory<CR>", { silent = true, desc = "All file history" })
      vim.keymap.set("n", "<Leader>gdr", "<Cmd>set operatorfunc=v:lua.Diffview_file_history<CR>g@",
        { silent = true, desc = "Ranged file history" })
      vim.keymap.set("n", "<Leader>gdcf", function()
        dv.file_history(nil, { "--range=ORIG_HEAD..FETCH_HEAD" })
      end, { silent = true, desc = "Fetched" })
      vim.keymap.set("n", "<Leader>gdch", function()
        dv.file_history(nil, { "--range=ORIG_HEAD..HEAD" })
      end, { silent = true, desc = "Head" })

      Configs.which_key.add({
        { "g",   group = "Git" },
        { "gb",  group = "Blame" },
        { "gd",  group = "Diffview" },
        { "gdc", group = "Commits" },
      }, { "<Leader>" })

      local function patch_include()
        local fname = vim.v.fname
        return fname:gsub("^[ab]/", "")
      end

      return {
        patch_include = patch_include,
      }
    '';
  extraFiles.ftplugin = {
    "git.lua" = # lua
      ''
        vim.opt_local.includeexpr = "v:lua.Configs.git.patch_include()"
      '';

    "fugitive.lua" = # lua
      ''
        local log_count = 50

        vim.opt_local.foldmethod = "syntax"

        local maps = {
          p = { command = "pull", desc = "Pull" },
          f = { command = "fetch", desc = "Fetch" },
          P = { command = "push", desc = "Push" },
          l = { command = "log -" .. log_count, desc = "Log " .. log_count },
          L = { command = "log -" .. (log_count * 2), desc = "Log " .. (log_count * 2) },
        }

        for key, mapping in pairs(maps) do
          vim.keymap.set(
            "n", "<Leader>g" .. key,
            "<Cmd>Git " .. mapping.command .. "<CR>",
            { desc = mapping.desc, buffer = true })
        end

        if vim.b.fugitive_type == "index" then
          vim.keymap.set("n", "R", "<Cmd>Git<CR>", { buffer = true })
        end

        Configs.which_key.add({ { "<Leader>g", group = "Git" } })
      '';
  };
}
