{ pkgs, lib, ... }: {
  name = "completion";
  plugins = with pkgs.vimPlugins; [
    nvim-cmp
    lspkind-nvim
    cmp-buffer
    cmp-path
    cmp-calc
    cmp-nvim-lsp
    cmp_luasnip
    copilot-vim
    (CopilotChat-nvim.overrideAttrs (old: {
      dependencies = lib.remove pkgs.vimPlugins.copilot-lua old.dependencies;
    }))

    nvim-autopairs
    nvim-ts-autotag
  ];
  packages = with pkgs; [ fd ];
  config = # lua
    ''
      local cmp = require("cmp")
      local lk = require("lspkind")
      local cc = require("cmp.config.compare")

      local default_sources = {
        nvim_lsp = { name = "nvim_lsp" },
        luasnip = { name = "luasnip" },
        path = { name = "path", options = { fd_timeout_msec = 1000, fd_cmd = { "fd", "-d", "4", "-p" } } },
        calc = { name = "calc" },
        buffer = { name = "buffer", option = { get_bufnrs = function() return vim.api.nvim_list_bufs() end } },
      }

      cmp.setup({
        sources = vim.tbl_values(default_sources),
        sorting = {
          priority_weight = 4,
          comparators = {
            cc.offset,
            cc.exact,
            cc.score,
            cc.recently_used,
            cc.kind,
            cc.sort_text,
            cc.length,
            cc.order,
          },
        },
        snippet = {
          expand = function(args)
            Configs.snippets.lsp_expand(args.body)
          end,
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
        formatting = {
          format = lk.cmp_format({
            mode = "symbol_text",
            menu = {
              nvim_lsp = "[LSP]",
              luasnip = "[SNIP]",
              path = "[P]",
              buffer = "[B]",
              calc = "[C]",
              ["vim-dadbod-completion"] = "[DB]",
            }
          })
        },
        experimental = {
          ghost_text = true,
        },
      })

      vim.g.copilot_no_maps = true
      vim.g.copilot_filetypes = { TelescopePrompt = false, DressingInput = false }

      vim.keymap.set("i", "<C-o>", 'copilot#Accept("")', { expr = true, replace_keycodes = false })
      vim.keymap.set("i", "<C-S-o>", "copilot#AcceptLine()", { expr = true, replace_keycodes = false })
      vim.keymap.set("i", "<M-o>", "copilot#AcceptWord()", { expr = true, replace_keycodes = false })
      vim.keymap.set("i", "<M-[>", "<Cmd>call copilot#Previous()<CR>", { silent = true })
      vim.keymap.set("i", "<M-]>", "<Cmd>call copilot#Next()<CR>", { silent = true })

      local cch = require("CopilotChat")
      local ccs = require("CopilotChat")
      local cca = require("CopilotChat.actions")
      local ccit = require("CopilotChat.integrations.telescope")

      cch.setup({
        mappings = {
          complete = {
            insert = "",
          },
        },
        model = "claude-3.5-sonnet",
        chat_autocomplete = true
      })

      vim.keymap.set({ "n", "v" }, "<Leader>CC", "<Cmd>CopilotChat<CR>", { desc = "Chat" })
      vim.keymap.set("n", "<Leader>Cb", function()
        cch.open({ selection = ccs.buffer })
      end, { desc = "Chat buffer" })
      vim.keymap.set("n", "<Leader>fC", function()
        ccit.pick(cca.help_actions())
      end, { desc = "Copilot chat actions" })

      vim.treesitter.language.register("diff", "copilot-diff")
      vim.treesitter.language.register("markdown", "copilot-chat")

      require("nvim-autopairs").setup({
        disable_filetype = { "TelescopePrompt", "dap-repl", "dapui_watches" },
      })

      cmp.event:on(
        "confirm_done",
        require("nvim-autopairs.completion.cmp").on_confirm_done({
          -- map <CR> on insert mode
          map_cr = false,
          -- it will auto insert `()` after select function or method item
          map_complete = true,
          -- automatically select the first item
          auto_select = true
        })
      )

      local function cmp_text_changed()
        if require("cmp.config").enabled() then
          cmp.core:on_change("TextChanged")
        end
      end

      require("nvim-ts-autotag").setup({
        opts = {
          enable_close_on_slash = true
        }
      })

      Configs.which_key.add({ { "<Leader>C", group = "Copilot chat" } })

      return {
        cmp_setup = cmp.setup,
        default_sources = default_sources,
        lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(),
        text_changed = cmp_text_changed
      }
    '';
}
