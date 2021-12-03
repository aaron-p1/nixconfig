{ config, lib, ... }:
let
  cfg = config.within.networking;

  enabledOption = name:
    with lib;
    mkOption {
      type = types.bool;
      default = true;
      description = name;
    };

  mkStringSetOption = name:
    with lib;
    mkOption {
      type = with types; nullOr (attrsOf str);
      default = null;
      description = name;
    };

  # attrs -> string
  mkDnsmasqFile = with lib;
    attrs:
    concatStringsSep "\n" (mapAttrsToList (k: v: "address=/${k}/${v}") attrs);

in with lib; {
  options.within.networking = {
    enable = mkEnableOption "basic setup";

    firewall = enabledOption "firewall";

    nm = {
      enable = enabledOption "NetworkManager";
      dnsmasq = {
        enable = enabledOption "dnsmasq";
        localDomains = mkStringSetOption "local domains";
        networkDomains = mkStringSetOption "network domains";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.useDHCP = false; # discouraged

    networking.firewall = {
      enable = cfg.firewall;
      allowPing = true;
    };

    networking.networkmanager = {
      enable = true;
      dns = optionalString cfg.nm.dnsmasq.enable "dnsmasq";
    };

    environment.etc."NetworkManager/dnsmasq.d/local" =
      optionalAttrs (cfg.nm.dnsmasq.localDomains != null) {
        text = mkDnsmasqFile cfg.nm.dnsmasq.localDomains;
      };

    environment.etc."NetworkManager/dnsmasq.d/network" =
      optionalAttrs (cfg.nm.dnsmasq.networkDomains != null) {
        text = mkDnsmasqFile cfg.nm.dnsmasq.networkDomains;
      };
  };
}
