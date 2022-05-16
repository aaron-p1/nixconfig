{ config, lib, ... }:
let cfg = config.within.networking.nm;
in with lib; {
  options.within.networking.nm = {
    enable = mkEnableOption "NetworkManager";

    dns = mkOption {
      type = types.str;
      default = "default";
      description = "dns";
    };

    nameservers = mkOption {
      type = with types; listOf str;
      default = [];
      description = "nameservers before dhcp";
    };

    dhcp = mkOption {
      type = types.str;
      default = "internal";
      description = "dhcp";
    };
  };

  config = mkIf cfg.enable {
    # enabled by default
    networking.dhcpcd.enable = cfg.dhcp == "dhcpcd";

    networking.networkmanager = {
      enable = true;
      inherit (cfg) dns dhcp;
      insertNameservers = cfg.nameservers;
    };
  };
}
