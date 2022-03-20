{ config, lib, ... }:
let
  cfg = config.within.networking;

  v6Prefix = cfg.v6.loopbackPrefix;
  v6PrefixString = lib.optionalString (v6Prefix != null) v6Prefix;
  prependV6Prefix = lib.mapAttrs (name: value: v6PrefixString + value);

  splitLocalAddresses = with lib;
    let
      attrList = mapAttrsToList nameValuePair cfg.localDomains;
      partitionList = partition (attr: hasInfix "." attr.value) attrList;
    in {
      v4 = listToAttrs partitionList.right;
      v6 = listToAttrs partitionList.wrong;
    };

  realLocalDomains = splitLocalAddresses.v4
    // prependV6Prefix splitLocalAddresses.v6;

  v6LoopbackAddresses = cfg.v6.loopbackAddresses
    ++ lib.attrValues splitLocalAddresses.v6;

  mappedV6LoopbackAddresses = builtins.map (value: {
    address = cfg.v6.loopbackPrefix + value;
    prefixLength = cfg.v6.loopbackPrefixLength;
  }) v6LoopbackAddresses;

  mkDefaultTrue = name:
    with lib;
    mkOption {
      type = types.bool;
      default = true;
      description = name;
    };

  mkDomainOption = name:
    with lib;
    mkOption {
      type = with types; attrsOf str;
      default = { };
      description = name;
    };

in with lib; {
  imports = [ ./networkmanager.nix ./dnsmasq.nix ./blocky.nix ];

  options.within.networking = {
    enable = mkEnableOption "basic setup";

    allowPing = mkDefaultTrue "allow ping";

    v4.redirectLoopback80 = mkDefaultTrue "redirect port 80 to 8000";

    v6 = {
      redirectLoopback80 = mkDefaultTrue "redirect port 80 to 8000";

      loopbackPrefix = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          loopback prefix. Must not end with ":".
          Generate via https://simpledns.plus/private-ipv6
        '';
      };
      loopbackPrefixLength = mkOption {
        type = types.int;
        default = 0;
        description = "loopback prefix length";
      };

      loopbackAddresses = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = "host parts of addresses to assign to dev lo";
      };
    };

    dns = mkOption {
      type = types.enum [ "none" "networkmanager" "dnsmasq" "blocky" ];
      default = "none";
      description = "dns server to use";
    };

    nameservers = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "nameservers to use";
    };

    localDomains = mkDomainOption ''
      local domains. Only IPv6 specify host part of IPv6 addresses
    '';
    networkDomains = mkDomainOption "network domains";
  };

  config = mkIf cfg.enable (mkMerge [{
    assertions = let
      c6LP = cfg.v6.loopbackPrefix;
      c6LPL = cfg.v6.loopbackPrefixLength;
    in [
      {
        assertion = length v6LoopbackAddresses > 0 -> c6LP != null;
        message = ''
          If local IPv6 loopback addresses are defined, you have to define
          within.networking.v6.ipv6LoopbackPrefix and
          within.networking.v6.ipv6LoopbackPrefixLength because
          within.networking.v6.loopbackAddresses only contains the host part.
        '';
      }
      {
        assertion = c6LP != null -> length (remove "" (splitString ":" c6LP))
          == builtins.ceil (c6LPL / 16.0);
        message = ''
          The option within.networking.v6.ipv6LoopbackPrefix defines more bits
          than there are defined in within.networking.v6.ipv6LoopbackPrefixLength.
        '';
      }
      {
        assertion = c6LP != null -> !(hasSuffix ":" c6LP || hasInfix "::" c6LP);
        message = ''
          The option within.networking.v6.ipv6LoopbackPrefix must not end
          with ':' and must not use '::'.
        '';
      }
      {
        assertion = length (attrValues (cfg.localDomains // cfg.networkDomains))
          > 0 -> builtins.elem cfg.dns [ "dnsmasq" "blocky" ];
        message = ''
          The option within.networking.localDomains or
          within.networking.networkDomains is defined, but the dns backend
          is not compatible.
        '';
      }
    ];

    networking = {
      nameservers =
        if (cfg.dns == "none") then cfg.nameservers else [ "127.0.0.1" ];
      useDHCP = false; # discouraged

      firewall = {
        inherit (cfg) allowPing;
        enable = true;
        extraCommands = optionalString cfg.v4.redirectLoopback80 ''
          iptables -t nat -A OUTPUT -d 127.32.0.0/16 -p tcp -m tcp --dport 80 -j DNAT --to-destination ':8000'
        '' + optionalString
          (cfg.v6.redirectLoopback80 && cfg.v6.loopbackPrefix != null) ''
            ip6tables -t nat -A OUTPUT -d ${cfg.v6.loopbackPrefix}::/64 -p tcp -m tcp --dport 80 -j DNAT --to-destination ':8000'
          '';
      };

      interfaces.lo.ipv6.addresses = mappedV6LoopbackAddresses;
    };

    within.networking = {
      nm = mkIf (cfg.dns == "networkmanager") {
        enable = true;
        dns = "internal";
        inherit (cfg) nameservers;
      };
      dnsmasq = mkIf (cfg.dns == "dnsmasq") {
        enable = true;
        mapDomains = cfg.networkDomains // realLocalDomains;
        servers = cfg.nameservers;
      };
      blocky = mkIf (cfg.dns == "blocky") {
        enable = true;
        mapDomains = cfg.networkDomains // realLocalDomains;
        inherit (cfg) nameservers;
      };
    };
  }]);
}
