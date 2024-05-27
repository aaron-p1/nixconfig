{ config, lib, pkgs, ... }:
let
  inherit (builtins) match readFile isAttrs listToAttrs;
  inherit (lib)
    concatMap concatMapAttrs concatStringsSep filter isPath isString makeBinPath
    mapAttrs mapAttrsToList mkEnableOption mkIf optionals optionalString pipe
    throwIfNot unique;

  cfg = config.within.neovim-new;

  domains = [
    ./utils.nix
    ./base.nix
    ./features.nix
    ./common.nix
    ./ui.nix
    ./treesitter.nix
    ./snippets.nix
    ./completion.nix
    ./git.nix
    ./telescope.nix
    ./lsp.nix
    ./files.nix
  ];

  defaultValues = {
    name = null;
    plugins = [ ];
    packages = [ ];
    config = null;
    extraFiles = { };
  };

  domainsValues = pipe domains [
    (map (domain: defaultValues // import domain { inherit lib pkgs; }))

    (map (values:
      if isPath values.config then
        values // { config = readFile values.config; }
      else
        values))

    (map (values:
      let cond = values.name != null && (match "[a-z_-]*" values.name) != null;
      in throwIfNot cond "Neovim config domain name invalid" values))
  ];

  plugins = pipe domainsValues [ (concatMap (domain: domain.plugins)) unique ];

  packages =
    pipe domainsValues [ (concatMap (domain: domain.packages)) unique ];

  wrapperArgs = optionals (packages != [ ]) [
    "--suffix"
    "PATH"
    ":"
    "${makeBinPath packages}"
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

          if fn then
            if is_running[k] then
              error('Recursive config call detected: ' .. k)
            end

            is_running[k] = true

            local value = fn()

            is_running[k] = false

            rawset(t, k, value)
            return value
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
    if isPath value then
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
          cat > $out${name} <<EOF
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
    '') extraFileLists;

  rtpCommands = pipe extraFilePackages [
    (map (extraFilePackage:
      ''vim.opt.runtimepath:prepend("${extraFilePackage}")''))
    (concatStringsSep "\n")
    (cmd: cmd + "\n\n")
  ];

  luaRcContent = (optionalString (extraFileLists != { }) rtpCommands)
    + domainConfigs;

  neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped {
    packpathDirs.myNeovimPackages = {
      start = plugins;
      opt = [ ];
    };
    inherit wrapperArgs luaRcContent;
  };
in {
  options.within.neovim-new = {
    enable = mkEnableOption "Neovim New";

    # TODO remove
    out = lib.mkOption {
      type = lib.types.package;
      default = neovim;
      readOnly = true;
    };
  };

  config = mkIf cfg.enable { home.packages = [ neovim ]; };
}
