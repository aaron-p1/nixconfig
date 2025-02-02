{ config, lib, ... }:
let
  inherit (builtins) attrNames;
  inherit (lib) mapAttrs' mkEnableOption mkOption mkIf mkDefault;
  inherit (lib.types) attrsOf str;

  cfg = config.within.networking.reverseProxy;

  devDomain = "dev.home.arpa";

  addedHosts = mapAttrs' (name: host: {
    name = "${name}.${devDomain}";
    value = { locations."/".proxyPass = host; };
  }) cfg.devHosts;
in {
  options.within.networking.reverseProxy = {
    enable = mkEnableOption "Reverse Proxy";

    devHosts = mkOption {
      type = attrsOf str;
      default = { };
      description = "Virtual host accessible at <name>.${devDomain}";
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
          serverName = "_";
          locations."/".return = 404;
        };
      } // addedHosts;
    };
  };
}
