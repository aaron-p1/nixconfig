{ pkgs, ... }: {
  within.neovim.configDomains.completion = {
    plugins = with pkgs.vimPlugins; [
      blink-cmp
      vim-dadbod-completion

      copilot-vim
      codecompanion-nvim

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
            ["<C-e>"] = { "hide", "fallback" },
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

        require("codecompanion").setup({
          strategies = {
            chat = {
              adapter = "copilot",
            },
            inline = {
              adapter = "copilot",
            },
          },
          adapters = {
            copilot = function()
              return require("codecompanion.adapters").extend("copilot", {
                schema = {
                  model = {
                    default = "claude-3.5-sonnet",
                  },
                  max_tokens = {
                    default = 65536,
                  },
                },
              })
            end,
          },
          display = {
            chat = {
              intro_message = "Press ? for options",
              -- show_settings = true,
            }
          }
        })

        require("plugins.codecompanion.fidget-spinner"):init()

        vim.keymap.set({ "n", "v" }, "<Leader>Ca", "<Cmd>CodeCompanionActions<CR>", { desc = "Actions", silent = true })
        vim.keymap.set({ "n", "v" }, "<Leader>Cc", "<Cmd>CodeCompanionChat Toggle<CR>", { desc = "Chat", silent = true })
        vim.keymap.set("v", "<Leader>Cv", "<Cmd>CodeCompanionChat Add<CR>", { desc = "Add text to chat", silent = true })

        -- Expand 'cc' into 'CodeCompanion' in the command line
        vim.cmd([[cabbrev cc CodeCompanion]])

        require("nvim-autopairs").setup({
          disable_filetype = { "TelescopePrompt", "dap-repl", "dapui_watches" },
        })

        require("nvim-ts-autotag").setup({
          opts = {
            enable_close_on_slash = true
          }
        })

        Configs.which_key.add({ { "<Leader>C", group = "Code Companion" } })

        return {
          lsp_capabilities = require("blink.cmp").get_lsp_capabilities(),
        }
      '';
    extraFiles.lua.plugins.codecompanion."fidget-spinner.lua" = # lua
      ''
        local progress = require("fidget.progress")

        local M = {}

        function M:init()
          local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

          vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "CodeCompanionRequestStarted",
            group = group,
            callback = function(request)
              local handle = M:create_progress_handle(request)
              M:store_progress_handle(request.data.id, handle)
            end,
          })

          vim.api.nvim_create_autocmd({ "User" }, {
            pattern = "CodeCompanionRequestFinished",
            group = group,
            callback = function(request)
              local handle = M:pop_progress_handle(request.data.id)
              if handle then
                M:report_exit_status(handle, request)
                handle:finish()
              end
            end,
          })
        end

        M.handles = {}

        function M:store_progress_handle(id, handle)
          M.handles[id] = handle
        end

        function M:pop_progress_handle(id)
          local handle = M.handles[id]
          M.handles[id] = nil
          return handle
        end

        function M:create_progress_handle(request)
          return progress.handle.create({
            title = " Requesting assistance (" .. request.data.strategy .. ")",
            message = "In progress...",
            lsp_client = {
              name = M:llm_role_title(request.data.adapter),
            },
          })
        end

        function M:llm_role_title(adapter)
          local parts = {}
          table.insert(parts, adapter.formatted_name)
          if adapter.model and adapter.model ~= "" then
            table.insert(parts, "(" .. adapter.model .. ")")
          end
          return table.concat(parts, " ")
        end

        function M:report_exit_status(handle, request)
          if request.data.status == "success" then
            handle.message = "Completed"
          elseif request.data.status == "error" then
            handle.message = " Error"
          else
            handle.message = "󰜺 Cancelled"
          end
        end

        return M
      '';
  };
}
