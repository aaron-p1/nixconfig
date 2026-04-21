{ pkgs, ... }:
{
  within.neovim.configDomains.completion = {
    plugins = with pkgs.vimPlugins; [
      blink-cmp
      vim-dadbod-completion

      {
        plugin = copilot-vim;
        optional = true;
      }

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
              lsp = {
                name = "LSP",
                fallbacks = { },
              },
              path = {
                name = "PTH",
                fallbacks = { },
              },
              snippets = {
                name = "SNP",
                score_offset = 0
              },
              buffer = {
                name = "BUF",
                opts = {
                  get_bufnrs = function ()
                    return vim.api.nvim_list_bufs()
                  end,
                  max_async_buffer_size = 2000000, -- 2MB
                  max_total_buffer_size = 5000000, -- 5MB
                },
              },

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

            ["<Tab>"] = { "fallback" },
            ["<S-Tab>"] = { "fallback" },

            ["<C-S-e>"] = { "show_signature", "hide_signature", "fallback" },
          },

          appearance = { use_nvim_cmp_as_default = true },
        })

        if not vim.env.NVIM_PRIVATE_CODE then
          vim.cmd("packadd copilot.vim")

          vim.g.copilot_no_tab_map = true
          vim.g.copilot_filetypes = { TelescopePrompt = false, DressingInput = false }

          vim.keymap.set("i", "<C-o>", 'copilot#Accept("")', { expr = true, replace_keycodes = false })
          vim.keymap.set("i", "<C-S-o>", "copilot#AcceptLine()", { expr = true, replace_keycodes = false })
          vim.keymap.set("i", "<M-o>", "copilot#AcceptWord()", { expr = true, replace_keycodes = false })
          vim.keymap.set("i", "<M-[>", "<Cmd>call copilot#Previous()<CR>", { silent = true })
          vim.keymap.set("i", "<M-]>", "<Cmd>call copilot#Next()<CR>", { silent = true })
        end

        require("nvim-autopairs").setup({
          disable_filetype = { "TelescopePrompt", "dap-repl", "dapui_watches" },
        })

        require("nvim-ts-autotag").setup({
          opts = {
            enable_close_on_slash = true
          }
        })

        return {
          lsp_capabilities = require("blink.cmp").get_lsp_capabilities(),
        }
      '';
  };
}
