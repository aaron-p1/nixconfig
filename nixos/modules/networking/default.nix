{ config, lib, ... }:
let
  inherit (builtins) length head match;
  inherit (lib)
    mkEnableOption mkOption mkIf attrValues hasPrefix hasSuffix filter optionals
    allUnique all;
  inherit (lib.types) attrsOf strMatching;

  cfg = config.within.networking;

  bindAddrList = attrValues cfg.bindAddrsV4;

  reservesPort = addr: hasPrefix "127.0.0.1:" addr || hasPrefix "0.0.0.0:" addr;
  onlyOneWithPort = port:
    length (filter (hasSuffix ":${port}") bindAddrList) == 1;
in {
  imports = [ ./dnscrypt.nix ];

  options.within.networking = {
    enable = mkEnableOption "Custom networking options";

    enableBindAddrChecking =
      mkEnableOption "Enable bind addrs checking for services" // {
        default = true;
      };

    bindAddrsV4 = mkOption {
      type = attrsOf (strMatching "^(127\\..*|0\\.0\\.0\\.0):[0-9]+$");
      default = { };
      description = ''
        Bind addresses for services. { name = "ipv4:port"; }

        Ip must be unique, ipv4, start with 127. or 0.0.0.0.
        If 127.0.0.1 or 0.0.0.0 is used, no other bindAddr can use the same port
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = optionals cfg.enableBindAddrChecking [
      {
        assertion = allUnique bindAddrList;
        message =
          "within.networking.bindAddrsV4: all bind addresses must be unique";
      }
      {
        assertion = all (addr:
          let port = head (match ".*:(.*)$" addr);
          in reservesPort addr -> onlyOneWithPort port) bindAddrList;
        message =
          "within.networking.bindAddrsV4: only one address can use a port"
          + " if addr is 127.0.0.1 or 0.0.0.0";
      }
    ];

    networking = {
      useDHCP = false;

      firewall = {
        enable = true;
        allowPing = true;
        pingLimit = "--limit 1/minute --limit-burst 5";

        extraCommands = ''
          iptables -t nat -A OUTPUT -d 127.32.0.0/16 -p tcp -m tcp --dport 80 -j DNAT --to-destination ':8000'
        '';
      };

      networkmanager.enable = true;
      dhcpcd.enable = false;
    };
  };
}
