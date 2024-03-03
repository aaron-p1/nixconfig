{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.within.networking.dnsmasq;

  mkDnsmasqDomains = attrs:
    lib.concatStrings (lib.mapAttrsToList (k: v: ''
      address=/${k}/${v}
    '') attrs);

in {
  options.within.networking.dnsmasq = {
    enable = mkEnableOption "dnsmasq";

    servers = mkOption {
      type = types.listOf types.str;
      default = config.networking.nameservers;
      description = "nameservers used by dnsmasq";
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = "extra config for dnsmasq";
    };

    mapDomains = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "domains to ip mappings";
    };
  };

  config = mkIf cfg.enable {
    services.dnsmasq = {
      enable = true;
      inherit (cfg) servers;
      extraConfig = cfg.extraConfig + "\n" + mkDnsmasqDomains cfg.mapDomains;
    };
  };
}
