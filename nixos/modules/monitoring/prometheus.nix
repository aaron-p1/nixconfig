{ config, lib, ... }:
let cfg = config.within.monitoring.prometheus;
in with lib; {
  options.within.monitoring.prometheus = {
    enable = mkEnableOption "Prometheus";

    addr = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "IP of web interface, API";
    };

    port = mkOption {
      type = types.port;
      default = 9090;
      description = "Port of web interface, API";
    };

    exporters = {
      node = {
        enable = mkEnableOption "System metrics";

        ip = mkOption {
          type = types.str;
          description = "Ip of exporter";
        };
        port = mkOption {
          type = types.port;
          default = 9100;
          description = "Port of exporter";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.prometheus = {
      enable = true;
      listenAddress = cfg.addr;
      inherit (cfg) port;

      exporters = let ex = cfg.exporters;
      in mkMerge [
        (mkIf ex.node.enable {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            listenAddress = ex.node.ip;
            inherit (ex.node) port;
          };
        })
      ];

      scrapeConfigs = let ex = config.services.prometheus.exporters;
      in concatLists [
        (optional ex.node.enable {
          job_name = "system";
          static_configs = [{
            targets = [ "${ex.node.listenAddress}:${toString ex.node.port}" ];
          }];
        })
      ];
    };
  };
}
