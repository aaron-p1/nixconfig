{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    attrValues
    listToAttrs
    nameValuePair
    ;

  cfg = config.within.networking.devService;
  rcfg = config.within.networking.reverseProxy;

  services = attrValues cfg.services;

  dnscryptCloaks = listToAttrs (
    map (service: nameValuePair "${service.subdomain}.${rcfg.devDomain}" service.ip) services
  );

  reverseProxyHosts = listToAttrs (
    map (
      service:
      nameValuePair service.subdomain {
        dst = "http://${service.ip}";
        redirectRoot = service.redirectRoot;
      }
    ) services
  );
in
{
  options.within.networking.devService =
    let
      inherit (lib) mkEnableOption mkOption;
      inherit (lib.types)
        attrsOf
        submodule
        bool
        str
        nullOr
        ;
    in
    {
      enable = mkEnableOption "Development Services";

      services = mkOption {
        default = { };
        description = "Dev services available in tailnet";
        type = attrsOf (
          submodule (
            { name, ... }:
            {
              options = {
                enable = mkOption {
                  type = bool;
                  default = true;
                  description = "Enable the service";
                };
                subdomain = mkOption {
                  type = str;
                  description = "Subdomain to use for the service";
                  default = name;
                };
                ip = mkOption {
                  type = str;
                  description = "IP to proxy to";
                };
                redirectRoot = mkOption {
                  type = nullOr str;
                  description = "Redirect root to another URL";
                  default = null;
                };
              };
            }
          )
        );
      };
    };

  config = mkIf cfg.enable {
    within.networking = {
      # cloaks for local DNS resolution
      dnscrypt.cloak = dnscryptCloaks;
      reverseProxy = {
        enable = true;
        devHosts = reverseProxyHosts;
      };
    };
  };
}
