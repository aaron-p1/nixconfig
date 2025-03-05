{ config, lib, pkgs, ... }:
let
  inherit (builtins) readFile isAttrs listToAttrs concatLists;
  inherit (lib)
    attrValues concatMap concatMapAttrs concatStringsSep filter isPath hasPrefix
    isString makeBinPath mapAttrs mapAttrsToList mkEnableOption mkIf optionals
    optionalString pipe unique;

  cfg = config.within.neovim;

  domainList = attrValues cfg.configDomains;

  overlays = filter (o: o != null) (map (domain: domain.overlay) domainList);
  plugins = unique (concatMap (domain: domain.plugins) domainList);
  packages = unique (concatMap (domain: domain.packages) domainList);

  lua = pkgs.neovim-unwrapped.lua;

  luaEnv = lua.withPackages (ps:
    pipe domainList [
      (filter (domain: domain.luaPackages != null))
      (map (domain: domain.luaPackages ps))
      concatLists
      unique
    ]);

  wrapperArgs = optionals (packages != [ ]) [
    "--suffix"
    "PATH"
    ":"
    "${makeBinPath packages}"
  ] ++ optionals (luaEnv != null) [
    "--prefix"
    "LUA_PATH"
    ";"
    (lua.pkgs.luaLib.genLuaPathAbsStr luaEnv)
    "--prefix"
    "LUA_CPATH"
    ";"
    (lua.pkgs.luaLib.genLuaCPathAbsStr luaEnv)
  ];

  toConfig = configAttrs:
    # lua
    ''
      local is_running = {}

      Configs = {
        init = function(t, k)
          local existing = rawget(t, k)

          if existing then
            return existing
          end

          local fn = rawget(t, '_' .. k)

          if fn and type(fn) == 'function' then
            if is_running[k] then
              error('Recursive config call detected: ' .. k)
            end

            is_running[k] = true

            local value = fn()

            is_running[k] = false

            rawset(t, k, value)
            return value
          else
            error('No config found for ' .. k)
          end
        end,
      }

      Configs = setmetatable(Configs, { __index = Configs.init })

      ${configAttrs.functions}

      ${configAttrs.inits}
    '';

  singleDomainConfig = { name, config }:
    # lua
    ''
      function Configs._${name}()
        ${config}
      end
    '';

  domainConfigs = pipe domainList [
    (filter (domain: domain.config != null))

    (map (domain: {
      name = domain.name;
      config =
        if isPath domain.config then readFile domain.config else domain.config;
    }))

    (configs: {
      functions = concatStringsSep "\n" (map singleDomainConfig configs);
      inits = concatStringsSep "\n"
        (map (config: ''Configs:init("${config.name}")'') configs);
    })

    toConfig
  ];

  flattenAttrs' = prefix: attrs:
    concatMapAttrs (name: value:
      if isAttrs value then
        flattenAttrs' (prefix + "/" + name) value
      else {
        ${prefix + "/" + name} = value;
      }) attrs;

  flattenAttrs = flattenAttrs' "";

  readExtraFiles = mapAttrs (_: value:
    if isPath value || isString value && hasPrefix "/" value then
      readFile value
    else if isString value then
      value
    else
      throw "Extra file must be path or string");

  extraFileLists = pipe domainList [
    (filter (domain: domain.extraFiles != { }))
    (map (domain: {
      inherit (domain) name;
      value = readExtraFiles (flattenAttrs domain.extraFiles);
    }))
    listToAttrs
  ];

  toExtraFileDirCommands = fileAttrs:
    pipe fileAttrs [
      (mapAttrsToList (name: value: dirOf name))
      unique
      (map (dir: "mkdir -p $out${dir}"))
      (concatStringsSep "\n")
    ];

  toExtraFileCommands = fileAttrs:
    pipe fileAttrs [
      (mapAttrsToList (name: value: # bash
        ''
          cat > $out${name} <<'EOF'
          ${value}
          EOF
        ''))
      (concatStringsSep "\n")
    ];

  extraFilePackages = mapAttrsToList (name: files:
    pkgs.runCommand "neovim-extra-files-${name}" { } ''
      mkdir -p $out

      ${toExtraFileDirCommands files}
      ${toExtraFileCommands files}

      ${pkgs.buildPackages.luaPackages.luacheck}/bin/luacheck \
        --std luajit --globals vim Configs --no-max-line-length \
        --no-unused -- $out
    '') extraFileLists;

  rtpCommands = pipe extraFilePackages [
    (map (extraFilePackage: # lua
      ''vim.opt.runtimepath:prepend("${extraFilePackage}")''))
    (concatStringsSep "\n")
    (cmd: cmd + "\n\n")
  ];

  luaRcContent = (optionalString (extraFileLists != { }) rtpCommands)
    + domainConfigs;

  neovim = (pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    plugins = map (plugin: { inherit plugin; }) plugins;
    inherit wrapperArgs luaRcContent;

    # CopilotChat-nvim
    withPython3 = true;
  }).overrideAttrs (old: {
    doCheck = true;
    checkPhase = ''
      # is in /bin/nvim last line after -u
      luaRcFile=$(tail -n 1 $out/bin/nvim | grep -oP '.*-u \K\S*')

      # 131: Unused implicitly defined global variable.
      # 611: A line consists of nothing but whitespace.
      ${pkgs.buildPackages.luaPackages.luacheck}/bin/luacheck \
        --std luajit --globals vim --allow-defined --no-max-line-length \
        --no-unused --ignore 131 611 -- $luaRcFile
    '';
  });
in {
  imports = [
    ./utils.nix
    ./which-key.nix
    ./base.nix
    ./features.nix
    ./common.nix
    ./profiles.nix
    ./ui.nix
    ./treesitter.nix
    ./snippets.nix
    ./completion.nix
    ./git.nix
    ./telescope.nix
    ./lsp.nix
    ./files.nix
    ./dap.nix
    ./db.nix
  ];

  options.within.neovim = {
    enable = mkEnableOption "Neovim config";

    finalPackage = lib.mkOption {
      type = lib.types.package;
      default = neovim;
      readOnly = true;
    };

    configDomains = let
      inherit (lib) mkOption mergeOneOption isFunction;
      inherit (lib.types)
        mkOptionType attrs attrsOf submodule str nullOr oneOf path listOf
        package;

      function = mkOptionType {
        name = "function";
        description = "function";
        check = isFunction;
        merge = mergeOneOption;
      };

      domainModule = { name, config, ... }: {
        options = {
          name = mkOption {
            type = str;
            default = name;
            description = "Name";
          };

          overlay = mkOption {
            type = nullOr function;
            default = null;
            description = "Package overlay";
          };
          plugins = mkOption {
            type = listOf package;
            default = [ ];
            description = "Neovim plugins";
          };
          luaPackages = mkOption {
            type = nullOr function;
            default = null;
            description = "Lua packages to add to neovim";
          };
          packages = mkOption {
            type = listOf package;
            default = [ ];
            description = "Packages";
          };

          config = mkOption {
            type = oneOf [ (nullOr str) path ];
            default = null;
            description = "Lua config";
          };
          extraFiles = mkOption {
            type = attrs;
            default = { };
            description = "Extra files in rtp. `{ path = { to = content; }; }";
          };
        };
      };
    in mkOption {
      type = attrsOf (submodule domainModule);
      default = { };
      description = "Neovim config split in domains";
    };
  };

  config = mkIf cfg.enable {
    _module.args.nvimUtil.pluginOverlay = fn:
      (final: prev: {
        vimPlugins = prev.vimPlugins.extend (_: _:
          fn {
            inherit prev final;
            pvP = prev.vimPlugins;
          });
      });

    home.packages = [ neovim ];

    nixpkgs.overlays = overlays;
  };
}
