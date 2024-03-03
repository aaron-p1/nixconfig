{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.within.networking.blocky;

  blockLists = cfg.blockLists ++ cfg.blockListFile;
in {
  options.within.networking.blocky =
    let inherit (types) str nullOr listOf path attrsOf bool;
    in {
      enable = mkEnableOption "blocky";

      ip = mkOption {
        type = str;
        default = "127.0.0.1";
        description = "IPv4 to run blocky on";
      };

      httpPort = mkOption {
        type = nullOr str;
        default = null;
        description = "http address to listen on";
      };

      bootstrapDns = mkOption {
        type = str;
        default = "9.9.9.9";
        description = "used for resolving nameservers and blockLists";
      };

      nameservers = mkOption {
        type = listOf str;
        default = config.networking.nameservers;
        description = "nameservers";
      };

      blockLists = mkOption {
        type = listOf str;
        default = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
        ];
        description = "lists to enable blocking on";
      };
      blockListFile = mkOption {
        type = listOf path;
        default = [ ];
        description = "list of paths to blocklist file";
      };

      mapDomains = mkOption {
        type = attrsOf str;
        default = { };
        description = "domains to ip mappings";
      };

      prometheus = mkOption {
        type = bool;
        default = false;
        description = "enable prometheus monitoring. Needs httpPort";
      };
    };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = cfg.prometheus -> cfg.httpPort != null;
      message = "httpPort needed if prometheus is enabled";
    }];

    services.blocky = {
      enable = true;

      # https://0xerr0r.github.io/blocky/configuration
      settings = {
        inherit (cfg) bootstrapDns httpPort;
        ports.dns = "${cfg.ip}:53";
        upstreams.groups.default = cfg.nameservers;
        customDNS.mapping = cfg.mapDomains;
        blocking = {
          blackLists.default = blockLists;
          clientGroupsBlock.default = [ "default" ];
          loading.downloads = {
            attempts = 0;
            cooldown = "4s";
          };
        };
        log.level = "warn";
        prometheus.enable = cfg.prometheus;
      };
    };
  };
}
