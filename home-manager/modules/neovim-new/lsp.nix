# See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
{ pkgs, ... }: {
  name = "lsp";
  plugins = with pkgs.vimPlugins; [
    nvim-lspconfig
    SchemaStore-nvim
    none-ls-nvim
  ];
  packages = with pkgs;
    let
      nills = [ nil nixfmt-classic ];

      bashls = [ bash-language-server shellcheck shfmt ];

      rustAnalyzerLs = [ rust-analyzer rustfmt ];

      lsp = [
        sumneko-lua-language-server
        nodePackages.intelephense
        nodePackages.vscode-langservers-extracted # html css json
        nodePackages.yaml-language-server
        nodePackages."@tailwindcss/language-server"
        nodePackages.typescript-language-server
        vue-language-server
        clang-tools
        pyright
      ] ++ nills ++ bashls ++ rustAnalyzerLs;

      none-ls = [ editorconfig-checker prettierd ];
    in lsp ++ none-ls;
  config = let
    tsLib = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";

    # lua
  in ''
    local lc = require("lspconfig")

    local formatting_preferences = {
      html = "null-ls",
      javascript = "null-ls",
      json = "null-ls",
      vue = "null-ls",
    }

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
      local lua_rtp = vim.split(package.path, ";")

      table.insert(lua_rtp, "lua/?.lua")
      table.insert(lua_rtp, "lua/?/init.lua")

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
            runtime = { version = "LuaJIT", path = lua_rtp },
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

    setup("elixirls", { cmd = { "elixir-ls" } })

    setup("intelephense") -- php

    setup("html")
    setup("cssls")
    setup("tailwindcss", { filetypes = { "html", "blade", "scss", "javascript", "typescript", "vue" } })
    setup("ts_ls")
    setup("volar", { init_options = { typescript = { tsdk = "${tsLib}" } } })

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

    setup("rust_analyzer")

    setup("clangd")

    setup("pyright")

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
        d.credo
      },
      should_attach = function(bufnr)
        return not vim.tbl_contains(disabled_filetypes, vim.bo[bufnr].filetype)
      end,
      on_attach = default_config.on_attach,
      capabilities = default_config.capabilities
    })
  '';
}
