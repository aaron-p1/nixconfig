{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.within.networking.nm;
in {
  options.within.networking.nm = {
    enable = mkEnableOption "NetworkManager";

    dns = mkOption {
      type = types.str;
      default = "default";
      description = "dns";
    };

    nameservers = mkOption {
      type = types.listOf types.str;
      default = [ ];
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
