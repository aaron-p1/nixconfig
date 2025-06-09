# See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
{ pkgs, ... }: {
  within.neovim.configDomains.lsp = {
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      SchemaStore-nvim
      none-ls-nvim
      elixir-tools-nvim
    ];
    packages = with pkgs;
      let
        nills = [ nil nixfmt-classic ];

        bashls = [ bash-language-server shellcheck shfmt ];

        rustAnalyzerLs = [ rust-analyzer rustfmt ];

        elixir = [ elixir-ls inotify-tools ];

        lsp = [
          sumneko-lua-language-server
          nodePackages.intelephense
          nodePackages.vscode-langservers-extracted # html css json
          nodePackages.yaml-language-server
          nodePackages."@tailwindcss/language-server"
          nodePackages.typescript-language-server
          vue-language-server
          glsl_analyzer
          clang-tools
          pyright
        ] ++ nills ++ bashls ++ rustAnalyzerLs ++ elixir;

        none-ls = [ editorconfig-checker prettierd isort black ];
      in lsp ++ none-ls;
    config = let
      tsLib = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";

      vueTSPlugin = pkgs.vue-language-server
        + "/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin";

      # lua
    in ''
      local lc = require("lspconfig")

      local formatting_preferences = {
        html = "null-ls",
        javascript = "null-ls",
        json = "null-ls",
        vue = "null-ls",
      }

      ---@type table<string, string[]> {client_name: filename[]} `all` for all clients
      local file_blocklist = {}

      local function file_blocklist_add(client_name, patterns)
        if type(patterns) == "string" then
          patterns = { patterns }
        end

        if not file_blocklist[client_name] then
          file_blocklist[client_name] = {}
        end

        vim.list_extend(file_blocklist[client_name], patterns)
      end

      local function is_blocked(clientname, bufnr)
        local buf_name = vim.api.nvim_buf_get_name(bufnr)
        local client_patterns = file_blocklist[clientname] or {}
        local all_patterns = file_blocklist["all"] or {}
        local patterns = vim.list_extend(vim.list_slice(client_patterns), all_patterns)

        return vim.iter(patterns):any(function(pattern)
          return buf_name:match(pattern)
        end)
      end

      lc.util.on_setup = lc.util.add_hook_before(lc.util.on_setup, function(config)
        config.autostart = false

        local event_conf = config.filetypes
            and { event = "FileType", pattern = config.filetypes }
            or { event = "BufReadPost" }

        vim.api.nvim_create_autocmd(event_conf.event, {
          pattern = event_conf.pattern or "*",
          group = vim.api.nvim_create_augroup('lspconfig', { clear = false }),
          callback = function(ev)
            if is_blocked(config.name, ev.buf) then
              return
            end

            local client = vim.lsp.get_clients({ name = config.name })[1]

            if client then
              vim.lsp.buf_attach_client(ev.buf, client.id)
            else
              require('lspconfig.configs')[config.name].launch()
            end
          end
        })
      end)

      local function on_attach(client, bufnr)
        local tb = Configs.telescope.builtin

        local function mapkey(mode, key, cmd, opts)
          opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {})

          vim.keymap.set(mode, key, cmd, opts)
        end

        mapkey("n", "gd", function() tb.lsp_definitions({ jump_type = "never" }) end, { desc = "Definition" })
        mapkey("n", "gi", tb.lsp_implementations, { desc = "Implementations" })
        mapkey("n", "gr", tb.lsp_references, { desc = "References" })

        mapkey("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })
        mapkey("n", "<Leader>lD", vim.lsp.buf.type_definition, { desc = "Type Definition" })

        mapkey("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
        mapkey("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
        mapkey("n", "<Leader>ld", vim.diagnostic.open_float, { desc = "Show diagnostic" })
        mapkey("n", "<Leader>ltd", function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end, { desc = "Toggle Diagnostics" })

        mapkey("n", "<Leader>lf", function()
          local ft = vim.bo[bufnr].filetype
          vim.lsp.buf.format({ bufnr = bufnr, name = formatting_preferences[ft] })
        end, { desc = "Format" })
        mapkey("n", "<Leader>lc", vim.lsp.buf.code_action, { desc = "Code Action" })
        mapkey("n", "<Leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
        mapkey("n", "<Leader>ll", vim.lsp.codelens.run, { desc = "Codelens" })

        if client.server_capabilities.documentHighlightProvider then
          local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
          vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })

          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            group = group,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.document_highlight()
            end
          })

          vim.api.nvim_create_autocmd("CursorMoved", {
            group = group,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.clear_references()
            end
          })
        end

        Configs.which_key.add({
          { "l",  group = "LSP" },
          { "lt", group = "Toggle" }
        }, { "<Leader>", buffer = bufnr })
      end

      local default_config = {
        capabilities = vim.tbl_deep_extend(
          "force",
          Configs.completion.lsp_capabilities,
          { offsetEncoding = { "utf-16" } }
        ),
        on_attach = on_attach
      }

      local function setup(server, config)
        config = vim.tbl_deep_extend("force", default_config, config or {})

        lc[server].setup(config)
      end

      do
        local function get_plugin_paths()
          local packpaths = vim.split(vim.o.packpath, ',')

          local plugins_path = nil

          for _, path in ipairs(packpaths) do
            local p = path .. '/pack/myNeovimPackages/start'

            if vim.fn.isdirectory(p) == 1 then
              plugins_path = p
              break
            end
          end

          if not plugins_path then
            return {}
          end

          local plugins = {}

          for name, type in vim.fs.dir(plugins_path) do
            if type == 'link' then
              local target = vim.uv.fs_readlink(plugins_path .. '/' .. name) .. "/lua"

              if vim.fn.isdirectory(target) == 1 then
                table.insert(plugins, target)
              end
            end
          end

          return plugins
        end

        local library_paths = {
          vim.env.VIMRUNTIME,
          "''${3rd}/luv/library",
          unpack(get_plugin_paths())
        }

        setup("lua_ls", {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              diagnostics = { globals = { "vim", "Configs" } },
              workspace = {
                checkThirdParty = false,
                library = library_paths
              }
            }
          }
        })
      end

      setup("nil_ls", {
        settings = {
          ["nil"] = {
            formatting = { command = { "nixfmt" } },
            nix = {
              maxMemoryMB = 8192,
              flake = { autoEvalInputs = true }
            }
          }
        }
      })

      -- php
      setup("intelephense", {
        settings = { intelephense = { files = { maxSize = 2 * 1000 * 1000 } } }
      })

      setup("html")
      setup("cssls")
      setup("tailwindcss", {
        settings = {
          tailwindCSS = {
            includeLanguages = {
              elixir = "html-eex",
              eelixir = "html-eex",
              heex = "html-eex",
            },
          }
        }
      })
      setup("ts_ls", {
        init_options = {
          plugins = { {
            name = "@vue/typescript-plugin",
            location = "${vueTSPlugin}",
            languages = { "vue" }
          } }
        },
        filetypes = { "javascript", "typescript", "vue" }
      })
      setup("volar", {
        init_options = {
          typescript = { tsdk = "${tsLib}" },
          vue = { hybridMode = true }
        }
      })

      local json_schemas = require("schemastore").json.schemas({ ignore = { "task.json" } })

      for _, schema in ipairs(Configs.profiles.json_schemas()) do
        table.insert(json_schemas, schema)
      end

      setup("jsonls", {
        settings = {
          json = {
            validate = { enable = true },
            schemas = json_schemas
          }
        }
      })
      setup("yamlls")

      setup("graphql")

      setup("rust_analyzer", {
        settings = {
          ['rust-analyzer'] = {
            cargo = {
              buildScripts = {
                enable = vim.uv.fs_stat("build.rs") ~= nil and vim.secure.read("build.rs") ~= nil
              }
            }
          }
        }
      })

      setup("glsl_analyzer")

      setup("clangd")

      setup("pyright")

      local elixirls = require("elixir.elixirls")
      require("elixir").setup({
        projectionist = { enabled = false },
        nextls = { enable = false },
        elixirls = {
          enable = true,
          cmd = { "elixir-ls" },
          settings = elixirls.settings({
            enableTestLenses = true,
            suggestSpecs = true,
          }),
          on_attach = default_config.on_attach,
          capabilities = default_config.capabilities,
        }
      })

      local nls = require("null-ls")

      local disabled_filetypes = { "NvimTree" }

      local d = nls.builtins.diagnostics
      local f = nls.builtins.formatting

      nls.setup({
        sources = {
          d.editorconfig_checker.with({
            method = nls.methods.DIAGNOSTICS_ON_SAVE,
            disabled_filetypes = { "gitcommit" }
          }),
          f.prettierd,
          d.credo,

          -- python
          f.isort,
          f.black,
        },
        should_attach = function(bufnr)
          return not vim.tbl_contains(disabled_filetypes, vim.bo[bufnr].filetype)
        end,
        on_attach = default_config.on_attach,
        capabilities = default_config.capabilities
      })

      return {
        file_blocklist = {
          add = file_blocklist_add
        }
      }
    '';
  };
}
