{ config, lib, ... }:
let cfg = config.within.networking.blocky;
in with lib; {
  options.within.networking.blocky = {
    enable = mkEnableOption "blocky";

    ip = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "IPv4 to run blocky on";
    };

    httpPort = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "http address to listen on";
    };

    bootstrapDns = mkOption {
      type = types.str;
      default = "9.9.9.9";
      description = "used for resolving nameservers and blockLists";
    };

    nameservers = mkOption {
      type = with types; listOf str;
      default = config.networking.nameservers;
      description = "nameservers";
    };

    blockLists = mkOption {
      type = with types; listOf str;
      default = [
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
      ];
      description = "lists to enable blocking on";
    };

    mapDomains = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "domains to ip mappings";
    };

    prometheus = mkOption {
      type = types.bool;
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
        port = "${cfg.ip}:53";
        upstream.default = cfg.nameservers;
        customDNS.mapping = cfg.mapDomains;
        conditional.mapping = { "." = "192.168.178.1"; };
        blocking = {
          blackLists.default = cfg.blockLists;
          clientGroupsBlock.default = [ "default" ];
          downloadAttempts = -1;
          downloadCooldown = "4s";
        };
        logLevel = "warn";
        prometheus.enable = cfg.prometheus;
      };
    };
  };
}
