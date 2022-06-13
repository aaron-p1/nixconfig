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
  };

  config = mkIf cfg.enable {
    services.blocky = {
      enable = true;

      # https://0xerr0r.github.io/blocky/configuration
      settings = {
        inherit (cfg) bootstrapDns;
        port = "${cfg.ip}:53";
        upstream.default = cfg.nameservers;
        customDNS.mapping = cfg.mapDomains;
        blocking = {
          blackLists.default = cfg.blockLists;
          clientGroupsBlock.default = [ "default" ];
          downloadAttempts = -1;
          downloadCooldown = "4s";
        };
        logLevel = "warn";
      };
    };
  };
}
