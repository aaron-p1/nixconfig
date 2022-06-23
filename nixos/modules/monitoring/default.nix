{ config, lib, pkgs, ... }:
let
  cfg = config.within.monitoring;

  domain = "monitoring";
  ip = "127.64.0.2";
in with lib; {
  imports = [ ./monitored ./grafana.nix ./prometheus.nix ];

  options.within.monitoring = {
    enable = mkEnableOption "Default monitoring config";
  };

  config = mkIf cfg.enable {
    within = {
      networking.localDomains."${domain}" = ip;
      monitoring = {
        grafana = {
          enable = true;
          listenAddr = "${domain}:80";

          plugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
          datasources = { prometheus.enable = true; };
        };
        prometheus = {
          enable = true;
          addr = ip;
          port = 9090;

          exporters = {
            node = {
              enable = true;
              inherit ip;
              port = 9100;
            };
          };
        };

        monitored = {
          blocky = {
            prometheus = {
              enable = true;
              defaultHttpPort = "${ip}:9053";
            };
            queryLog.enable = true;
          };
        };
      };
    };
  };
}
