{ config, lib, ... }:
let
  inherit (builtins) head match split;
  inherit (lib)
    toInt mkEnableOption mkOption types mkIf optional mapAttrsToList;

  cfg = config.within.monitoring.grafana;

  domain = head (split ":[[:digit:]]*$" cfg.listenAddr);
  inherit (config.within.networking) localDomains;
  http_addr =
    if domain == "localhost" then "127.0.0.1" else localDomains."${domain}";
  http_port = toInt (head (match ".*:([[:digit:]]+)" cfg.listenAddr));
in {
  options.within.monitoring.grafana = {
    enable = mkEnableOption "Grafana";

    listenAddr = mkOption {
      type = types.str;
      default = "localhost:3000";
      description = "Address of webgui. (domain:port)";
    };

    plugins = mkOption {
      type = types.nullOr (types.listOf types.path);
      default = null;
      description = "Plugins in pkgs.grafanaPlugins";
    };

    datasources = {
      prometheus = { enable = mkEnableOption "Prometheus source"; };
    };

    dashboards = mkOption {
      default = { };
      description = "dashboards to provision";
      type = types.attrsOf (types.submodule {
        options = {
          folder = mkOption {
            type = types.str;
            default = "";
            description = "folder for dashboards";
          };
          foldersFromFilesStructure = mkOption {
            type = types.bool;
            default = false;
            description = "create folders from filesystem";
          };
          path = mkOption {
            type = types.path;
            description = "directory of dashboards";
          };
        };
      });
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = domain != null;
        message = "Domain missing";
      }
      {
        assertion = localDomains ? "${domain}";
        message = "Domain '${domain}' missing in localDomains";
      }
      {
        assertion = http_addr != null;
        message = "Address missing";
      }
      {
        assertion = http_port != null;
        message = "Port missing";
      }
    ];

    services.grafana = {
      enable = true;

      settings.server = { inherit domain http_addr http_port; };

      declarativePlugins = cfg.plugins;
      provision = {
        enable = true;

        datasources.settings.datasources = let ds = cfg.datasources;
        in optional ds.prometheus.enable {
          name = "Prometheus";
          uid = "systemprom";
          type = "prometheus";
          url = let prom = config.services.prometheus;
          in "http://${prom.listenAddress}:${toString prom.port}";
          access = "proxy"; # "Server" in GUI
        };

        dashboards.settings.providers = let ds = cfg.datasources;
        in (optional ds.prometheus.enable {
          name = "System";
          type = "file";
          folder = "system";
          updateIntervalSeconds = 10;
          disableDeletion = false;
          options = {
            path = ./grafana-resources/dashboards/system;
            foldersFromFilesStructure = false;
          };
        }) ++ (mapAttrsToList (name: val: {
          type = "file";
          inherit name;
          inherit (val) folder;
          updateIntervalSeconds = 10;
          disableDeletion = false;
          options = { inherit (val) path foldersFromFilesStructure; };
        }) cfg.dashboards);
      };
    };
  };
}
