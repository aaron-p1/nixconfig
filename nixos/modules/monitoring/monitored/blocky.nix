{ config, lib, ... }:
let
  cfg = config.within.monitoring.monitored.blocky;

  mysqlSocket = "/run/mysqld/mysqld.sock";
in with lib; {
  options.within.monitoring.monitored.blocky = {
    prometheus = {
      enable = mkEnableOption "Monitoring of blocky with prometheus";

      defaultHttpPort = mkOption {
        type = types.str;
        description = "httpPort to use when no other is specified";
      };
    };
    queryLog = {
      enable = mkEnableOption "Querry logging";

      database = mkOption {
        type = types.str;
        default = "monitoring_blocky";
        description = "Database to use in mysql";
      };
      user = mkOption {
        type = types.str;
        default = "blocky";
        description = "DB User to use. Should be the user blocky runs as";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.prometheus.enable {
      within = {
        networking.blocky = {
          httpPort = mkDefault cfg.prometheus.defaultHttpPort;
          prometheus = true;
        };
        monitoring.grafana.dashboards.BlockyPrometheus = {
          folder = "blocky";
          path = ../grafana-resources/dashboards/blocky/prometheus;
        };
      };

      services.prometheus.scrapeConfigs = [{
        job_name = "blocky";
        static_configs =
          [{ targets = [ "${config.within.networking.blocky.httpPort}" ]; }];
      }];
    })
    (mkIf cfg.queryLog.enable {
      within = {
        mysql.enable = true;
        monitoring.grafana.dashboards.BlockyQueryLog = {
          folder = "blocky";
          path = ../grafana-resources/dashboards/blocky/query-log;
        };
      };

      services = let inherit (cfg.queryLog) database user;
      in {
        blocky.settings.queryLog = {
          type = "mysql";
          target = "${user}@unix(${mysqlSocket})/${database}?charset=utf8mb4";
        };
        mysql = {
          ensureDatabases = [ database ];
          ensureUsers = [
            {
              name = user;
              ensurePermissions = { "${database}.*" = "ALL PRIVILEGES"; };
            }
            {
              name = "grafana";
              ensurePermissions = { "${database}.*" = "SELECT"; };
            }
          ];
        };
        grafana.provision.datasources = [{
          name = "Blocky";
          uid = "mysqlblocky";
          type = "mysql";
          url = mysqlSocket;
          user = "grafana";
          inherit database;
          jsonData.timezone = "+00:00";
          editable = true; # see afterupdate
        }];
      };
    })
  ];
}
