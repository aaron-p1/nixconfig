{ pkgs, lib, nvimUtil, ... }: {
  within.neovim.configDomains.completion = {
    overlay = nvimUtil.pluginOverlay ({ pvP, ... }: {
      CopilotChat-nvim = pvP.CopilotChat-nvim.overrideAttrs
        (old: { dependencies = lib.remove pvP.copilot-lua old.dependencies; });
    });
    plugins = with pkgs.vimPlugins; [
      blink-cmp
      vim-dadbod-completion

      copilot-vim
      CopilotChat-nvim

      nvim-autopairs
      nvim-ts-autotag
    ];
    packages = with pkgs; [ fd ];
    config = # lua
      ''
        local bcmp = require("blink.cmp")

        bcmp.setup({
          sources = {
            default = { "lsp", "path", "snippets", "buffer", "dadbod" },

            providers = {
              lsp = { name = "LSP" },
              path = { name = "PTH" },
              snippets = {
                name = "SNP",
                score_offset = 0
              },
              buffer = { name = "BUF" },

              dadbod = { name = "DBD", module = "vim_dadbod_completion.blink" },
            },
          },

          cmdline = {
            sources = function()
              local type = vim.fn.getcmdtype()
              if type == ':' or type == '@' then return { 'cmdline' } end
              return {}
            end
          },

          snippets = { preset = "luasnip" },

          completion = {
            list = {
              selection = {
                preselect = false,
              }
            },

            menu = {
              draw = {
                columns = {
                  { 'kind_icon' },
                  { 'label', 'label_description', gap = 1 },
                  { 'source_name' },
                }
              }
            },

            accept = {
              create_undo_point = false,
            },

            documentation = {
              auto_show = true,
              auto_show_delay_ms = 200,
            },

            ghost_text = {
              enabled = false,
              show_with_selection = false,
              show_without_selection = true,
            }
          },

          signature = {
            enabled = true,
          },

          keymap = {
            preset = "none",
            ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            ["<C-e>"] = { "hide" },
            ["<C-y>"] = { "select_and_accept" },

            ["<C-p>"] = { "select_prev", "fallback" },
            ["<C-n>"] = { "select_next", "fallback" },

            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },

            ["<Tab>"] = { "select_next", "fallback" },
            ["<S-Tab>"] = { "select_prev", "fallback" },

            ["<C-S-e>"] = { "show_signature", "hide_signature", "fallback" },
          },

          appearance = { use_nvim_cmp_as_default = true },
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

        require("nvim-ts-autotag").setup({
          opts = {
            enable_close_on_slash = true
          }
        })

        Configs.which_key.add({ { "<Leader>C", group = "Copilot chat" } })

        return {
          lsp_capabilities = require("blink.cmp").get_lsp_capabilities(),
        }
      '';
  };
}
