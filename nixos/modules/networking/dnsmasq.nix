{ config, lib, ... }:
let
  cfg = config.within.networking.dnsmasq;

  mkDnsmasqDomains = attrs:
    lib.concatStrings (lib.mapAttrsToList (k: v: ''
      address=/${k}/${v}
    '') attrs);

  mkDomainOption = name:
    with lib;
    mkOption {
      type = with types; attrsOf str;
      default = { };
      description = name;
    };

in with lib; {
  options.within.networking.dnsmasq = {
    enable = mkEnableOption "dnsmasq";

    servers = mkOption {
      type = with types; listOf str;
      default = config.networking.nameservers;
      description = "nameservers used by dnsmasq";
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "extra config for dnsmasq";
    };

    mapDomains = mkOption {
      type = with types; attrsOf str;
      default = { };
      description = "domains to ip mappings";
    };
  };

  config = mkIf cfg.enable {
    # enabled by default
    networking.dhcpcd.enable = false;

    services.dnsmasq = {
      enable = true;
      inherit (cfg) servers;
      extraConfig = cfg.extraConfig + "\n"
        + mkDnsmasqDomains cfg.mapDomains;
    };
  };
}
