{ config, lib, ... }:
let
  inherit (builtins) attrNames isString;
  inherit (lib)
    listToAttrs
    flatten
    mapAttrsToList
    nameValuePair
    mkEnableOption
    mkOption
    mkIf
    mkDefault
    ;
  inherit (lib.types)
    attrsOf
    either
    str
    submodule
    nullOr
    ;

  cfg = config.within.networking.reverseProxy;

  defaultHostConfig = {
    redirectRoot = null;
  };

  hostMapping =
    name: host:
    let
      serverName = "${name}.${cfg.devDomain}";

      hostConfig = defaultHostConfig // (if isString host then { dst = host; } else host);

      proxyConfig = {
        proxyPass = hostConfig.dst;
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_pass_header Authorization;
        '';
      };
    in
    if hostConfig.redirectRoot != null then
      [
        (nameValuePair serverName {
          locations."/".return = "302 ${hostConfig.redirectRoot}";
        })
        (nameValuePair "*.${serverName}" { locations."/" = proxyConfig; })
      ]
    else
      nameValuePair serverName {
        serverAliases = [ "*.${serverName}" ];
        locations."/" = proxyConfig;
      };

  addedHosts = listToAttrs (flatten (mapAttrsToList hostMapping cfg.devHosts));
in
{
  options.within.networking.reverseProxy = {
    enable = mkEnableOption "Reverse Proxy";

    devDomain = mkOption {
      type = str;
      default = "dev.home.arpa";
      description = "Domain to use for development services";
    };

    devHosts = mkOption {
      type = attrsOf (
        either str (
          submodule (
            { ... }:
            {
              options = {
                dst = mkOption {
                  type = str;
                  description = "URL to proxy to";
                };
                redirectRoot = mkOption {
                  type = nullOr str;
                  default = defaultHostConfig.redirectRoot;
                  description = "Redirect / on domain to this URL";
                };
              };
            }
          )
        )
      );
      default = { };
      description = ''
        Virtual host accessible at <name>.${cfg.devDomain}

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
      }
      // addedHosts;
    };

    systemd.services.nginx.after = [ "dnscrypt-proxy2.service" ];
  };
}
