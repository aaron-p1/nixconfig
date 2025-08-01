{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) attrsOf strMatching;

  cfg = config.within.networking;
in
{
  imports = [
    ./dnscrypt.nix
    ./reverse-proxy.nix
    ./dev-service.nix
  ];

  options.within.networking = {
    enable = mkEnableOption "Custom networking options";

    enableBindAddrChecking = mkEnableOption "Enable bind addrs checking for services" // {
      default = true;
    };

    bindAddrsV4 = mkOption {
      type = attrsOf (strMatching "^(127\\.[0-9.]*|0\\.0\\.0\\.0)(:[0-9]+)?$");
      default = { };
      description = ''
        Bind addresses for services. { name = "ipv4:port"; name2 = "ipv4"; }

        Ip must be unique, ipv4, start with 127. or 0.0.0.0.
        If 127.0.0.1 or 0.0.0.0 is used, no other bindAddr can use the same port
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions =
      let
        inherit (builtins) partition length elemAt;
        inherit (lib)
          mapAttrsToList
          optionalAttrs
          attrValues
          findFirst
          any
          optionals
          allUnique
          splitString
          ;

        bindV4List = mapAttrsToList (
          name: addr:
          let
            split = splitString ":" addr;
          in
          {
            inherit name;
            ip = elemAt split 0;
          }
          // optionalAttrs (length split == 2) { port = elemAt split 1; }
        ) cfg.bindAddrsV4;

        portBinds = partition (bind: bind ? port) bindV4List;

        zeroOnly = findFirst (bind: bind.ip == "0.0.0.0") null portBinds.wrong;

        wholeIpAndPort = findFirst (
          bind: (any (pb: bind.ip == pb.ip) portBinds.right)
        ) null portBinds.wrong;

        zeroAndIp = findFirst (
          bind: bind.ip != "0.0.0.0" && (any (b: b.ip == "0.0.0.0" && b.port == bind.port) portBinds.right)
        ) null portBinds.right;
      in
      optionals cfg.enableBindAddrChecking [
        {
          assertion = allUnique (attrValues cfg.bindAddrsV4);
          message = "within.networking.bindAddrsV4: all bind addresses must be unique";
        }
        {
          assertion = zeroOnly == null;
          message = "within.networking.bindAddrsV4: ${zeroOnly.name} is bound to 0.0.0.0";
        }

        {
          assertion = wholeIpAndPort == null;
          message = "within.networking.bindAddrsV4: ${wholeIpAndPort.name} binds whole ip, but port bind exists";
        }

        {
          assertion = zeroAndIp == null;
          message = "within.networking.bindAddrsV4: port ${zeroAndIp.port} is bound to 0.0.0.0 and ${zeroAndIp.ip}";
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
