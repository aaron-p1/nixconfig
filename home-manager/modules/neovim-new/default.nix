{ config, lib, pkgs, ... }:
let
  inherit (builtins) match readFile isAttrs listToAttrs concatLists;
  inherit (lib)
    concatMap concatMapAttrs concatStringsSep filter isPath hasPrefix isString
    makeBinPath mapAttrs mapAttrsToList mkEnableOption mkIf optionals
    optionalString pipe throwIfNot unique;

  cfg = config.within.neovim-new;

  domains = [
    ./utils.nix
    ./which_key.nix
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

  defaultValues = {
    name = null;
    plugins = [ ];
    packages = [ ];
    luaPackages = _: [ ];
    config = null;
    extraFiles = { };
  };

  localVimPlugins = import ./local-plugins.nix { inherit lib pkgs; };

  domainsValues = pipe domains [
    (map (domain:
      defaultValues // import domain { inherit lib pkgs localVimPlugins; }))

    (map (values:
      if isPath values.config then
        values // { config = readFile values.config; }
      else
        values))

    (map (values:
      let cond = values.name != null && (match "[a-z_]*" values.name) != null;
      in throwIfNot cond "Neovim config domain name invalid" values))
  ];

  plugins = pipe domainsValues [ (concatMap (domain: domain.plugins)) unique ];

  packages =
    pipe domainsValues [ (concatMap (domain: domain.packages)) unique ];

  lua = pkgs.neovim-unwrapped.lua;

  luaEnv = lua.withPackages (ps:
    pipe domainsValues [
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

  singleDomainConfig = domain:
    # lua
    ''
      function Configs._${domain.name}()
        ${domain.config}
      end
    '';

  domainConfigs = pipe domainsValues [
    (filter (domain: domain.config != null))

    (domains: {
      functions = concatStringsSep "\n" (map singleDomainConfig domains);
      inits = concatStringsSep "\n"
        (map (domain: ''Configs:init("${domain.name}")'') domains);
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

  extraFileLists = pipe domainsValues [
    (filter (values: isAttrs values.extraFiles && values.extraFiles != { }))
    (map (values: {
      inherit (values) name;
      value = readExtraFiles (flattenAttrs values.extraFiles);
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
    packpathDirs.myNeovimPackages = {
      start = plugins;
      opt = [ ];
    };
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
  options.within.neovim-new = {
    enable = mkEnableOption "Neovim New";

    finalPackage = lib.mkOption {
      type = lib.types.package;
      default = neovim;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable { home.packages = [ neovim ]; };
}
