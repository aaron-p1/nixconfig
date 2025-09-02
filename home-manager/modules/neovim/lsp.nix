# See https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
{
  pkgs,
  lib,
  config,
  ...
}:
{
  within.neovim.configDomains.lsp = {
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      SchemaStore-nvim
      none-ls-nvim
      elixir-tools-nvim
    ];
    packages =
      with pkgs;
      let
        bwrap =
          pkg:
          {
            bin ? pkg.meta.mainProgram,
            net ? false,
            withRootNix ? false,
            extraHomeMounts ? [ ],
          }:
          let
            args = [
              "--unshare-user"
              # enabling pid would crash lsp servers after seconds
              # "--unshare-pid"
              "--unshare-net"
              "--unshare-ipc"
              "--unshare-cgroup"
              "--unshare-uts"
              "--die-with-parent"
              "--proc /proc"
              "--dev /dev"
              "--tmpfs /tmp"
            ]
            ++ (if withRootNix then [ "--ro-bind /nix /nix" ] else [ "--ro-bind /nix/store /nix/store" ])
            ++ [
              "--ro-bind /run/current-system/sw /run/current-system/sw"
              "--ro-bind /etc/profiles/per-user/aaron/bin /etc/profiles/per-user/aaron/bin"
              "--ro-bind /bin /bin"
              "--bind ${isoHome} /home/$USER"
              "--dir /home/$USER/.cache"
              ''--bind "$PWD" "$PWD"''
            ]
            ++ lib.optional net "--share-net"
            ++ homeMounts;

            isoHome = "${config.xdg.dataHome}/nvim/bwrap/home";
            homeMounts = map (m: ''--bind "/home/$USER/${m}" "/home/$USER/${m}"'') extraHomeMounts;
          in
          pkgs.writeShellScriptBin bin ''
            [[ -d "${isoHome}" ]] || mkdir -p "${isoHome}"

            additionalBWrapArgs=()

            if [[ -n "$DIRENV_FILE" ]]; then
              direnvDir="$(dirname "$DIRENV_FILE")/.direnv"

              if [[ -d "$direnvDir" ]]; then
                additionalBWrapArgs+=("--bind" "$direnvDir" "$direnvDir")
              fi
            fi

            exec ${pkgs.bubblewrap}/bin/bwrap \
              ${lib.concatStringsSep " " args} \
              "''${additionalBWrapArgs[@]}" \
              "${pkg}/bin/${bin}" "$@"
          '';

        nills = [
          (bwrap nil {
            net = true;
            withRootNix = true;
          })
          (bwrap nixfmt-rfc-style { })
        ];

        bashls = [
          (bwrap bash-language-server { })
          (bwrap shellcheck { })
          (bwrap shfmt { })
        ];

        rustAnalyzerLs = [
          (bwrap rust-analyzer { net = true; })
          (bwrap rustfmt { })
        ];

        elixir = [
          (bwrap elixir-ls {
            net = true;
            extraHomeMounts = [
              ".mix"
              ".hex"
            ];
          })
          # for mix phx.server code reloading
          inotify-tools
        ];

        lsp = [
          (bwrap sumneko-lua-language-server { })
          (bwrap nodePackages.intelephense {
            net = true;
            extraHomeMounts = [ "intelephense" ];
          })
          (bwrap nodePackages.vscode-langservers-extracted { bin = "vscode-html-language-server"; })
          (bwrap nodePackages.vscode-langservers-extracted { bin = "vscode-css-language-server"; })
          (bwrap nodePackages.vscode-langservers-extracted { bin = "vscode-json-language-server"; })
          (bwrap nodePackages.yaml-language-server { })
          (bwrap nodePackages."@tailwindcss/language-server" { })
          (bwrap nodePackages.typescript-language-server { })
          (bwrap vue-language-server { })
          (bwrap glsl_analyzer { })
          (bwrap clang-tools { bin = "clangd"; })
          (bwrap pyright { bin = "pyright-langserver"; })
          (bwrap haskell-language-server { bin = "haskell-language-server-wrapper"; })
        ]
        ++ nills
        ++ bashls
        ++ rustAnalyzerLs
        ++ elixir;

        none-ls = [
          (bwrap editorconfig-checker { })
          (bwrap prettierd { })
          (bwrap isort { })
          (bwrap black { })
        ];
      in
      lsp ++ none-ls;
    config =
      let
        tsLib = "${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib";

        vueTSPlugin =
          pkgs.vue-language-server
          + "/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin";

        # lua
      in
      ''
        vim.lsp.inlay_hint.enable()

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

        local old_lsp_start = vim.lsp.start
        vim.lsp.start = function(config, opts)
          if is_blocked(config.name, opts and opts.bufnr or 0) then
            return
          end

          return old_lsp_start(config, opts)
        end

        vim.api.nvim_create_autocmd("LspAttach", {
          group = vim.api.nvim_create_augroup("LspConfig", {}),
          callback = function(ev)
            local tb = Configs.telescope.builtin

            local function mapkey(mode, key, cmd, opts)
              opts = vim.tbl_extend("force", { buffer = ev.buf }, opts or {})

              vim.keymap.set(mode, key, cmd, opts)
            end

            mapkey("n", "gd", function() tb.lsp_definitions({ jump_type = "never" }) end, { desc = "Definition" })
            mapkey("n", "gri", tb.lsp_implementations, { desc = "Implementations" })
            mapkey("n", "grr", tb.lsp_references, { desc = "References" })

            mapkey("n", "gD", vim.lsp.buf.declaration, { desc = "Declaration" })
            mapkey("n", "grt", vim.lsp.buf.type_definition, { desc = "Type Definition" })

            mapkey("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous Diagnostic" })
            mapkey("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })
            mapkey("n", "grd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
            mapkey("n", "grD", function()
              vim.diagnostic.enable(not vim.diagnostic.is_enabled())
            end, { desc = "Toggle Diagnostics" })

            mapkey("n", "grf", function()
              local ft = vim.bo[ev.buf].filetype
              vim.lsp.buf.format({ bufnr = ev.buf, name = formatting_preferences[ft] })
            end, { desc = "Format" })
            mapkey("n", "gra", vim.lsp.buf.code_action, { desc = "Code Action" })
            mapkey("n", "grn", vim.lsp.buf.rename, { desc = "Rename" })
            mapkey("n", "grl", vim.lsp.codelens.run, { desc = "Codelens" })

            local client = vim.lsp.get_client_by_id(ev.data.client_id)
            if client and client.server_capabilities.documentHighlightProvider then
              local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
              vim.api.nvim_clear_autocmds({ buffer = ev.buf, group = group })

              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = group,
                buffer = ev.buf,
                callback = function()
                  vim.lsp.buf.document_highlight()
                end
              })

              vim.api.nvim_create_autocmd("CursorMoved", {
                group = group,
                buffer = ev.buf,
                callback = function()
                  vim.lsp.buf.clear_references()
                end
              })
            end
          end
        })

        local default_config = {}

        local function setup(server, config)
          config = vim.tbl_deep_extend("force", default_config, config or {})

          vim.lsp.config(server, config)
          vim.lsp.enable(server)
        end

        do
          local function get_plugin_paths()
            local plugins_path = vim.iter(vim.split(vim.o.packpath, ','))
                :map(function(path) return path .. '/pack/myNeovimPackages/start' end)
                :find(function(path) return vim.fn.isdirectory(path) == 1 end)

            if not plugins_path then
              return {}
            end

            return vim.iter(vim.fs.dir(plugins_path))
                :filter(function(_, type) return type == 'link' end)
                :map(function(name, _) return vim.uv.fs_readlink(plugins_path .. '/' .. name) .. "/lua" end)
                :filter(function(path) return vim.fn.isdirectory(path) == 1 end)
                :totable()
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
        setup("vue_ls", {
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
              fetchDeps = true,
              mixEnv = "dev",
              enableTestLenses = true,
              suggestSpecs = true,
            }),
          }
        })

        setup("hls")

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
        })

        return {
          file_blocklist = {
            add = file_blocklist_add,
            get = file_blocklist
          }
        }
      '';
  };
}
