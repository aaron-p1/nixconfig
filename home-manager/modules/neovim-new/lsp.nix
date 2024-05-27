{ pkgs, ... }: {
  name = "lsp";
  plugins = with pkgs.vimPlugins; [ nvim-lspconfig SchemaStore-nvim ];
  packages = with pkgs; [
    sumneko-lua-language-server

    nil
    nixfmt-classic

    nodePackages.intelephense
    # html css json
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    nodePackages."@tailwindcss/language-server"
    nodePackages.volar
  ];
  config = let
    tsLib = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";

    # lua
  in ''
    local lc = require("lspconfig")

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

      mapkey("n", "<Leader>ld", vim.diagnostic.open_float, { desc = "Show diagnostic" })

      mapkey("n", "<Leader>lf", vim.lsp.buf.format, { desc = "Format" })
      mapkey("n", "<Leader>lc", vim.lsp.buf.code_action, { desc = "Code Action" })
      mapkey("n", "<Leader>lr", vim.lsp.buf.rename, { desc = "Rename" })
      mapkey("n", "<Leader>ll", vim.lsp.codelens.run, { desc = "Codelens" })

      if client.server_capabilities.documentHighlightProvider then
        local group = vim.api.nvim_create_augroup("lsp_document_highlight", {})

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

      Configs.common.wk_register({
        prefix = "<Leader>",
        buffer = bufnr,
        map = { l = { name = "LSP" } }
      })
    end

    local default_config = {
      capabilities = Configs.completion.lsp_capabilities,
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

      setup("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT", path = lua_rtp },
            diagnostics = { globals = { "vim", "Configs" } },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME }
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

    setup("intelephense") -- php

    setup("html")
    setup("cssls")
    setup("tailwindcss")
    setup("tsserver")
    setup("volar", { init_options = { typescript = { tsdk = "${tsLib}" } } })

    setup("jsonls", {
      settings = {
        json = {
          validate = { enable = true },
          schemas = require("schemastore").json.schemas()
        }
      }
    })
    setup("yamlls")

    setup("graphql")
  '';
}
