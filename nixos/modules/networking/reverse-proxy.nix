{ config, lib, ... }:
let
  inherit (builtins) attrNames isString;
  inherit (lib) mapAttrs' mkEnableOption mkOption mkIf mkDefault optional;
  inherit (lib.types) attrsOf either str submodule bool;

  cfg = config.within.networking.reverseProxy;

  devDomain = "dev.home.arpa";

  defaultHostConfig = { allSubDomains = false; };

  hostMapping = name: host:
    let
      serverName = "${name}.${devDomain}";

      hostConfig = defaultHostConfig
        // (if isString host then { dst = host; } else host);
    in {
      name = serverName;
      value = {
        serverAliases = optional hostConfig.allSubDomains "*.${serverName}";
        locations."/" = {
          proxyPass = hostConfig.dst;
          proxyWebsockets = true;
          recommendedProxySettings = true;
          extraConfig = ''
            proxy_pass_header Authorization;
          '';
        };
      };
    };

  addedHosts = mapAttrs' hostMapping cfg.devHosts;
in {
  options.within.networking.reverseProxy = {
    enable = mkEnableOption "Reverse Proxy";

    devHosts = mkOption {
      type = attrsOf (either str (submodule ({ ... }: {
        options = {
          dst = mkOption {
            type = str;
            description = "URL to proxy to";
          };
          allSubDomains = mkOption {
            type = bool;
            default = defaultHostConfig.allSubDomains;
            description = "Proxy all subdomains";
          };
        };
      })));
      default = { };
      description = ''
        Virtual host accessible at <name>.${devDomain}

        Either str `dst` or submodule
      '';
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      tailscaleAuth = {
        enable = true;
        expectedTailnet = "hale-manta.ts.net";
        virtualHosts = attrNames addedHosts;
      };

      virtualHosts = {
        default = mkDefault {
          default = true;
          serverName = "_";
          locations."/".return = 404;
        };
      } // addedHosts;
    };

    systemd.services.nginx.after = [ "dnscrypt-proxy2.service" ];
  };
}
