{ lib, ... }: {
  name = "profiles";
  config = let
    inherit (builtins) toJSON;
    inherit (lib)
      mapAttrs pipe throwIfNot all hasAttr attrNames concatStringsSep
      mapAttrsToList filterAttrs;

    neovim-package-path = ".\\\\#nixosConfigurations.aaron-pc.config"
      + ".home-manager.users.aaron.within.neovim-new.finalPackage";

    profiles = {
      nixconfig.startup = # lua
        ''
          Configs.utils.add_term_keymaps("<Leader>cps", "sudo make switch")
          Configs.utils.add_term_keymaps("<Leader>cpb", "sudo make boot")

          Configs.utils.add_term_keymaps("<Leader>cpn", "nix shell --show-trace ${neovim-package-path}")
          Configs.utils.add_term_keymaps("<Leader>cpN", "nix run --show-trace ${neovim-package-path}")

          Configs.which_key.add({
            { "p",  group = "Profile" },
            { "ps", group = "Switch config" },
            { "pb", group = "Boot config" },
            { "pn", group = "Shell neovim" },
            { "pN", group = "Run neovim" }
          }, { "<Leader>c" })
        '';

      nixserver.startup = # lua
        ''
          local host = vim.env.NVIM_PROFILE_NIXSERVER_HOST

          Configs.utils.add_term_keymaps("<Leader>cpd", "deploy .\\\\#" .. host)
          Configs.utils.add_term_keymaps("<Leader>cpb", "deploy --boot .\\\\#" .. host)
          Configs.utils.add_term_keymaps("<Leader>cps", "ssh " .. host)
          Configs.utils.add_term_keymaps("<Leader>cpS", "ssh " .. host .. " -- exit")

          Configs.which_key.add({
            { "d", group = "Deploy to server" },
            { "b", group = "Deploy to server without switching" },
            { "s", group = "SSH to server" },
            { "S", group = "Only create SSH connection" }
          }, { "<Leader>cp" })
        '';

      laravel.startup = # lua
        ''
          local function get_compose_cmd(cmd)
            local container_options = vim.env.NVIM_PROFILE_PHP_CONTAINER_OPTIONS or ""
            local container = vim.env.NVIM_PROFILE_PHP_CONTAINER or ""

            return "podman-compose exec " .. container_options .. " " .. container .. " " .. (cmd or "")
          end

          local has_sail = has_profile("sail")
          local has_podman_compose = has_profile("podman_compose")
          local php_tinker_cmd = "php artisan tinker"
          local tinker_cmd =
              has_sail and "sail tinker"
              or has_podman_compose and get_compose_cmd(php_tinker_cmd)
              or php_tinker_cmd

          Configs.utils.add_term_keymaps("<Leader>cpl", "tail -f storage/logs/laravel.log")
          Configs.utils.add_term_keymaps("<Leader>cpL", "less storage/logs/laravel.log")

          Configs.utils.add_term_keymaps("<Leader>cpt", tinker_cmd)

          Configs.which_key.add({
            { "p",  group = "Profile" },
            { "pt", name = "Tinker" },
            { "pl", name = "Tail laravel log" },
            { "pL", name = "Less laravel log" }
          }, { "<Leader>c" })

          if has_sail or has_podman_compose then
            local shell_cmd = has_sail and "sail root-shell" or get_compose_cmd("bash")

            Configs.utils.add_term_keymaps("<Leader>cps", shell_cmd)

            Configs.which_key.add({ { "<Leader>cps", group = "Shell" } })
          end

          if has_profile("tenancy_for_laravel") then
            local tinker_tenant_artisan_cmd = " artisan tenants:run tinker"
            local php_tinker_tenant_cmd = "php" .. tinker_tenant_artisan_cmd
            local tinker_tenant_cmd =
                has_sail and "sail" .. tinker_tenant_artisan_cmd
                or has_podman_compose and get_compose_cmd(php_tinker_tenant_cmd)
                or php_tinker_tenant_cmd

            Configs.utils.add_term_keymaps("<Leader>cpT", tinker_tenant_cmd)

            Configs.which_key.add({ { "<Leader>cpT", group = "Tenant tinker" } })
          end

          if has_profile("npm") then
            local watch_cmd = "npm run watch"
            local prod_cmd = "npm run prod"

            local host_watch_cmd =
                has_sail and "sail " .. watch_cmd
                or has_podman_compose and get_compose_cmd(watch_cmd)
                or watch_cmd
            local host_prod_cmd =
                has_sail and "sail " .. prod_cmd
                or has_podman_compose and get_compose_cmd(prod_cmd)
                or prod_cmd

            Configs.utils.add_term_keymaps("<Leader>cpw", host_watch_cmd)
            Configs.utils.add_term_keymaps("<Leader>cpp", host_prod_cmd)

            Configs.which_key.add({
              { "w", group = "Npm watch" },
              { "p", group = "Npm prod" }
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
          Configs.utils.add_term_keymaps("<Leader>cpt", "cargo test")
          Configs.utils.add_term_keymaps("<Leader>cpc", "cargo check")
          Configs.utils.add_term_keymaps("<Leader>cpC", "cargo clean")

          Configs.which_key.add({
            { "b", group = "Build" },
            { "B", group = "Build release" },
            { "d", group = "Open docs" },
            { "r", group = "Run" },
            { "t", group = "Test" },
            { "c", group = "Check" },
            { "C", group = "Clean" },
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

  in assert unknownProfileFunctions != { }
    -> throw "Unknown profile function: ${toJSON unknownProfileFunctions}";
  # lua
  ''
    local M = { profiles = {} }

    local profiles_string = vim.env.NVIM_PROFILES or ""
    local set_profiles = vim.split(profiles_string, ",", { plain = true, trimempty = true })

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
}
