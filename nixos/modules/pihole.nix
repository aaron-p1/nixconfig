{ config, lib, ... }:
let
  cfg = config.within.pihole;

  cfgNM = config.networking.networkmanager;
  isDnsmasqEnabled = cfgNM.enable && cfgNM.dns == "dnsmasq";

  # Other Name server. Always has at least 1 because of pihole
  otherDNS = []; #builtins.tail config.networking.nameservers;
  # NameServers before adding pihole
  dns = if builtins.length otherDNS == 0 then [
    "9.9.9.9"
    "149.112.112.112"
  ] else
    otherDNS;

  piholeDNS = lib.concatStringsSep ";" dns;
in with lib; {
  options.within.pihole = {
    enable = mkEnableOption "pihole";
    ip = mkOption {
      type = types.str;
      default = "127.128.0.2";
      description = "Local IP of container. Should start with 127";
    };
    domainName = mkOption {
      type = types.str;
      default = "pihole";
      description = "Domain name of container";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.pihole = {
      image = "docker.io/pihole/pihole:latest";
      ports =
        [ "${cfg.ip}:7999:53/tcp" "${cfg.ip}:7999:53/udp" "${cfg.ip}:80:80/tcp" ];
      environment = {
        TZ = "Europe/Berlin";
        PIHOLE_DNS_ = piholeDNS;
        VIRTUAL_HOST = cfg.domainName;
      };
      volumes = [
        "/etc/pihole/pihole:/etc/pihole/"
        "/etc/pihole/dnsmasq.d:/etc/dnsmasq.d/"
      ];
    };

    environment.etc = {
      "pihole/pihole/.createDir".text = "";
      "pihole/dnsmasq.d/.createDir".text = "";

      "NetworkManager/dnsmasq.d/pihole" = optionalAttrs isDnsmasqEnabled {
        text = ''
          server=${cfg.ip}#7999
          address=/${cfg.domainName}/${cfg.ip}
        '';
      };
    };

    networking.networkmanager.insertNameservers = [ "${cfg.ip}#7999" ];
  };
}
