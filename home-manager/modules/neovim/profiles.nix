{ lib, pkgs, ... }: {
  within.neovim.configDomains.profiles = {
    config = let
      inherit (builtins) toJSON;
      inherit (lib)
        mapAttrs pipe throwIfNot all hasAttr attrNames concatStringsSep
        mapAttrsToList filterAttrs;

      neovim-package-path = ".\\\\#nixosConfigurations.aaron-pc.config"
        + ".home-manager.users.aaron.within.neovim.finalPackage";

      nix-inspect-bin = "${pkgs.nix-inspect}/bin/nix-inspect";

      profiles = {
        nixconfig.startup = # lua
          ''
            Configs.utils.add_term_keymaps("<Leader>cps", "sudo make switch")
            Configs.utils.add_term_keymaps("<Leader>cpS", "sudo make nixargs=--offline switch")
            Configs.utils.add_term_keymaps("<Leader>cpb", "sudo make boot")
            Configs.utils.add_term_keymaps("<Leader>cpB", "sudo make nixargs=--offline boot")

            Configs.utils.add_term_keymaps("<Leader>cpc", "${nix-inspect-bin} --path .", {}, true)

            Configs.utils.add_term_keymaps("<Leader>cpn", "nix shell --show-trace ${neovim-package-path}")
            Configs.utils.add_term_keymaps("<Leader>cpN", "nix run --show-trace ${neovim-package-path}")

            Configs.lsp.file_blocklist.add("all", "/snippets/init/")
            Configs.lsp.file_blocklist.add("clangd", "nsxiv/config.def.h$")

            Configs.which_key.add({
              { "p",  group = "Profile" },
              { "ps", group = "Switch config" },
              { "pS", group = "Switch config offline" },
              { "pb", group = "Boot config" },
              { "pB", group = "Boot config offline" },
              { "pc", group = "Explore config" },
              { "pn", group = "Shell neovim" },
              { "pN", group = "Run neovim" }
            }, { "<Leader>c" })
          '';

        nixserver.startup = # lua
          ''
            local host = profile_conf.nixserver_host or "invalid"

            Configs.utils.add_term_keymaps("<Leader>cpd", "deploy .\\\\#" .. host)
            Configs.utils.add_term_keymaps("<Leader>cpb", "deploy --boot .\\\\#" .. host)
            Configs.utils.add_term_keymaps("<Leader>cps", "ssh " .. host)
            Configs.utils.add_term_keymaps("<Leader>cpS", "ssh " .. host .. " -- exit")

            Configs.utils.add_term_keymaps("<Leader>cpc", "${nix-inspect-bin} --path .", {}, true)

            Configs.which_key.add({
              { "p",  group = "Profile" },
              { "pd", group = "Deploy to server" },
              { "pb", group = "Deploy to server without switching" },
              { "ps", group = "SSH to server" },
              { "pS", group = "Only create SSH connection" },
              { "pc", group = "Explore config" }
            }, { "<Leader>c" })
          '';

        laravel.startup = # lua
          ''
            local has_sail = has_profile("sail")
            local has_podman_compose = has_profile("podman_compose")

            local function get_compose_cmd(cmd)
              local container_options = profile_conf.php_container_options or ""
              local container = profile_conf.php_container or ""

              return "podman-compose exec " .. container_options .. " " .. container .. " " .. (cmd or "")
            end

            local function get_host_cmd(cmd, cmd_prefix)
              cmd_prefix = (cmd_prefix or "") .. " "

              return
                  has_sail and "sail " .. cmd
                  or has_podman_compose and get_compose_cmd(cmd_prefix .. cmd)
                  or cmd_prefix .. cmd
            end

            Configs.utils.add_term_keymaps("<Leader>cpl", "tail -f storage/logs/laravel.log")
            Configs.utils.add_term_keymaps("<Leader>cpL", "less storage/logs/laravel.log", {}, true)

            Configs.utils.add_term_keymaps("<Leader>cpt", get_host_cmd("tinker", "php artisan"))
            Configs.utils.add_term_keymaps("<Leader>cpq", get_host_cmd("artisan queue:listen", "php"))

            Configs.utils.add_term_keymaps("<Leader>cpmm", get_host_cmd("artisan migrate", "php"))
            Configs.utils.add_term_keymaps("<Leader>cpmr", get_host_cmd("artisan migrate:rollback", "php"))

            Configs.which_key.add({
              { "p",  group = "Profile" },
              { "pt", name = "Tinker" },
              { "pq", name = "Queue listen" },
              { "pl", name = "Tail laravel log" },
              { "pL", name = "Less laravel log" },
              { "pm", group = "Migrate" },
              { "pmm", name = "Migrate" },
              { "pmr", name = "Rollback" },
            }, { "<Leader>c" })

            if has_sail or has_podman_compose then
              local shell_cmd = has_sail and "sail root-shell" or get_compose_cmd("bash")

              Configs.utils.add_term_keymaps("<Leader>cps", shell_cmd)

              Configs.which_key.add({ { "<Leader>cps", group = "Shell" } })
            end

            if has_profile("tenancy_for_laravel") then
              Configs.utils.add_term_keymaps("<Leader>cpT", get_host_cmd("artisan tenants:run tinker", "php"))

              Configs.utils.add_term_keymaps("<Leader>cpmt", get_host_cmd("artisan tenants:migrate", "php"))
              Configs.utils.add_term_keymaps("<Leader>cpmT", get_host_cmd("artisan tenants:rollback", "php"))

              Configs.which_key.add({
                { "T", group = "Tenant tinker" },
                { "mt", name = "Tenant migrate" },
                { "mT", name = "Tenant rollback" },
              }, { "<Leader>cp" })
            end

            if has_profile("npm") then
              Configs.utils.add_term_keymaps("<Leader>cpnw", get_host_cmd("npm run watch"))
              Configs.utils.add_term_keymaps("<Leader>cpnd", get_host_cmd("npm run dev"))
              Configs.utils.add_term_keymaps("<Leader>cpnp", get_host_cmd("npm run prod"))
              Configs.utils.add_term_keymaps("<Leader>cpnb", get_host_cmd("npm run build"))

              Configs.which_key.add({
                { "n", group = "Npm" },
                { "nw", group = "Npm watch" },
                { "nd", group = "Npm dev" },
                { "np", group = "Npm prod" },
                { "nb", group = "Npm build" },
              }, { "<Leader>cp" })
            end
          '';

        xo.json_schemas = # lua
          ''
            local schema_path = vim.fn.getcwd() .. "/storage/app/schema"

            return {
              {
                url = schema_path .. "/fields.schema.json",
                fileMatch = { "storage/app/schema/fields/*.json" }
              }
            }
          '';

        elixir_phoenix.startup = # lua
          ''
            Configs.utils.add_term_keymaps("<Leader>cpd", "mix deps.get")
            Configs.utils.add_term_keymaps("<Leader>cps", "mix phx.server")
            Configs.utils.add_term_keymaps("<Leader>cpi", "iex -S mix")
            Configs.utils.add_term_keymaps("<Leader>cpI", "iex -S mix phx.server")
            Configs.utils.add_term_keymaps("<Leader>cpt", "mix test")

            Configs.which_key.add({
              { "d", group = "Get deps" },
              { "s", group = "Start server" },
              { "i", group = "Iex" },
              { "I", group = "Iex with server" },
              { "t", group = "Test" }
            }, { "<Leader>cp" })
          '';

        cargo.startup = # lua
          ''
            Configs.utils.add_term_keymaps("<Leader>cpb", "cargo build")
            Configs.utils.add_term_keymaps("<Leader>cpB", "cargo build --release")
            Configs.utils.add_term_keymaps("<Leader>cpd", "cargo doc --open")
            Configs.utils.add_term_keymaps("<Leader>cpr", "cargo run")
            Configs.utils.add_term_keymaps("<Leader>cpR", "cargo run --release")
            Configs.utils.add_term_keymaps("<Leader>cpt", "cargo test")
            Configs.utils.add_term_keymaps("<Leader>cpc", "cargo check")
            Configs.utils.add_term_keymaps("<Leader>cpC", "cargo clean")

            Configs.which_key.add({
              { "b", group = "Build" },
              { "B", group = "Build release" },
              { "d", group = "Open docs" },
              { "r", group = "Run" },
              { "R", group = "Run release" },
              { "t", group = "Test" },
              { "c", group = "Check" },
              { "C", group = "Clean" },
            }, { "<Leader>cp" })
          '';

        flask.startup = # lua
          ''
            Configs.utils.add_term_keymaps("<Leader>cpr", "python-fixed run.py")
            Configs.utils.add_term_keymaps("<Leader>cpt", "python-fixed -m pytest")

            Configs.which_key.add({
              { "r", group = "Run" },
              { "t", group = "Test" },
            }, { "<Leader>cp" })
          '';

        vite.startup = # lua
          ''
            Configs.utils.add_term_keymaps("<Leader>cpnd", "npm run dev")
            Configs.utils.add_term_keymaps("<Leader>cpnb", "npm run build")

            Configs.which_key.add({
              { "n", group = "Npm" },
              { "nd", group = "Npm dev" },
              { "nb", group = "Npm build" },
            }, { "<Leader>cp" })
          '';
      };

      functionConfigs = {
        startup.defaultReturn = "nil";
        json_schemas = {
          defaultReturn = "{}";
          merger = mergers.mergeLists;
        };
      };

      defaultValues = mapAttrs (_: _: null) functionConfigs;

      normalizedProfiles = pipe profiles [
        (mapAttrs (_: profile:
          throwIfNot (all (n: hasAttr n functionConfigs) (attrNames profile))
          "Unknown profile function" profile))
        (mapAttrs (_: profile: defaultValues // profile))
      ];

      luaProfileTableInits = pipe profiles [
        (mapAttrsToList (name: _: "M.profiles.${name} = {}"))
        (concatStringsSep "\n")
      ];

      toProfileFunctions = profileName: profile:
        pipe profile [
          (filterAttrs (_: value: value != null))
          (mapAttrsToList (functionName: lua: # lua
            ''
              function M.profiles.${profileName}.${functionName}()
                ${lua}
              end
            ''))
          (concatStringsSep "\n")
        ];

      luaProfileFunctions = pipe normalizedProfiles [
        (mapAttrsToList toProfileFunctions)
        (concatStringsSep "\n")
      ];

      mergers = {
        mergeLists = # lua
          ''
            if vim.islist(ir) then
              for _, v in ipairs(ir) do
                table.insert(result, v)
              end
            else
              error("Cannot merge type " .. type(ir) .. " with list")
            end
          '';
      };

      luaExecuters = pipe functionConfigs [
        (mapAttrsToList (functionName: config: # lua
          ''
            function M.${functionName}()
              local result = ${config.defaultReturn or "nil"};

              for _, profile in ipairs(set_profiles) do
                if M.profiles[profile] and M.profiles[profile].${functionName} then
                  local ir = M.profiles[profile].${functionName}()

                  ${config.merger or ""}
                end
              end

              return result
            end
          ''))

        (concatStringsSep "\n")
      ];

      unknownProfileFunctions = pipe profiles [
        (mapAttrs (_: profile:
          filterAttrs (name: _: !hasAttr name functionConfigs) profile))
        (filterAttrs (_: unknown: unknown != { }))
        (mapAttrs (_: attrNames))
      ];

      # profile files:
      # profiles = [ profile1, profile2 ]
      # [conf]
      # key = value

    in assert unknownProfileFunctions != { }
      -> throw "Unknown profile function: ${toJSON unknownProfileFunctions}";
    # lua
    ''
      local M = { profiles = {} }

      local set_profiles = {}
      local profile_conf = {}

      local profile_files = {}
      local profile_files_path = vim.fn.stdpath("data") .. "/custom_profiles"
      local profile_files_slash_esc = "⧸"
      local profile_files_ext = ".ini"

      vim.fn.mkdir(profile_files_path, "p")

      if vim.env.NVIM_PROFILES ~= nil then
        local profiles_string = vim.env.NVIM_PROFILES or ""
        set_profiles = vim.split(profiles_string, ",", { plain = true, trimempty = true })
      else
        local cwd = vim.fn.getcwd()
        local cwd_esc = cwd:gsub("/", profile_files_slash_esc)
        local files = vim.iter(vim.fs.dir(profile_files_path))
            :filter(function(name, type)
              local path_prefix = name
                  :gsub("%" .. profile_files_ext .. "$", "")
              return type == "file" and vim.startswith(cwd_esc, path_prefix)
            end)
            :map(function(name) return name end)
            :totable()

        table.sort(files, function(a, b) return #a < #b end)
        profile_files = files

        local conf_parser = require("profiles.conf_parser")

        local profile_config = vim.iter(files)
            :map(function(name)
              local full_name = profile_files_path .. "/" .. name
              return conf_parser.read_file(full_name)
            end)
            :fold({}, function(acc, conf)
              local profiles = vim.list_extend(acc.profiles or {}, conf.profiles or {})
              return vim.tbl_deep_extend("force", acc, conf, { profiles = profiles })
            end)

        set_profiles = profile_config.profiles or {}
        profile_conf = profile_config.conf or {}
      end

      vim.keymap.set("n", "<Leader>cpP", function()
        local fname = profile_files_path
            .. "/"
            .. vim.fn.getcwd():gsub("/", profile_files_slash_esc)
            .. profile_files_ext
        vim.cmd.tabedit(fname)
      end, { desc = "Edit current profile" })

      vim.keymap.set("n", "<Leader>cpp", function()
        if #profile_files == 0 then
          vim.notify("No profile files found", vim.log.levels.WARN)
          return
        end

        vim.ui.select(profile_files, {
          prompt = "Select profile file to edit",
          format_item = function(name)
            return name
                :gsub("%" .. profile_files_ext .. "$", "")
                :gsub(profile_files_slash_esc, "/")
          end,
        }, function(file)
          if file then
            vim.cmd.tabedit(profile_files_path .. "/" .. file)
          end
        end)
      end, { desc = "Edit profiles" })

      Configs.which_key.add({ { "<Leader>cp", group = "Profile" } })

      setmetatable(profile_conf, {
        __index = function(t, k)
          local existing = rawget(t, k)

          if existing then
            return existing
          end

          local env_key = "NVIM_PROFILE_" .. k:upper()
          return vim.env[env_key]
        end,
      })

      local function has_profile(profile)
        return vim.tbl_contains(set_profiles, profile)
      end

      ${luaProfileTableInits}

      ${luaProfileFunctions}

      ${luaExecuters}

      M.list_names = vim.tbl_keys(M.profiles)
      M.list_applied = set_profiles

      return M
    '';
    extraFiles.lua.profiles."conf_parser.lua" = # lua
      ''
        local M = {}

        function M.read_file(file)
          local result = {}
          local cur_section = result

          for line in io.lines(file) do
            line = vim.trim(line)

            if line:match("^%s*#") or line == "" then
              -- if comment or empty line, skip it
              goto continue
            elseif line:match("^%[.+%]$") then
              -- if section header
              cur_section = result

              line = line:sub(2, -2)
              for _, name in ipairs(vim.split(line, "%.")) do
                if not cur_section[name] then
                  cur_section[name] = {}
                end
                cur_section = cur_section[name]
              end
            elseif line:match("^%w") then
              -- if key-value pair
              local key, value = line:match("^(%w+)%s*=%s*(.+)$")
              if key and value then
                if value:match("^%[.+%]$") then
                  value = vim.iter(vim.split(value:sub(2, -2), ","))
                      :map(function(v) return vim.trim(v) end)
                      :filter(function(v) return v ~= "" end)
                      :map(function(v) return tonumber(v) or v end)
                      :totable()
                elseif tonumber(value) then
                  value = tonumber(value)
                end
              end

              cur_section[key] = value
            else
              -- if unrecognized line, skip it
              vim.notify("Conf parser: Unrecognized line: " .. line, vim.log.levels.WARN)
            end

            ::continue::
          end

          return result
        end

        return M
      '';
  };
}
