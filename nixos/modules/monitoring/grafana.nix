{ config, lib, ... }:
let
  cfg = config.within.monitoring.grafana;

  inherit (builtins) head match split;

  domain = head (split ":[[:digit:]]*$" cfg.listenAddr);
  inherit (config.within.networking) localDomains;
  addr =
    if domain == "localhost" then "127.0.0.1" else localDomains."${domain}";
  port = lib.toInt (head (match ".*:([[:digit:]]+)" cfg.listenAddr));
in with lib; {
  options.within.monitoring.grafana = {
    enable = mkEnableOption "Grafana";

    listenAddr = mkOption {
      type = types.str;
      default = "localhost:3000";
      description = "Address of webgui. (domain:port)";
    };

    plugins = mkOption {
      type = with types; nullOr (listOf path);
      default = null;
      description = "Plugins in pkgs.grafanaPlugins";
    };

    datasources = {
      prometheus = { enable = mkEnableOption "Prometheus source"; };
    };

    dashboards = mkOption {
      default = { };
      description = "dashboards to provision";
      type = with types;
        attrsOf (submodule {
          options = {
            folder = mkOption {
              type = str;
              default = "";
              description = "folder for dashboards";
            };
            foldersFromFilesStructure = mkOption {
              type = bool;
              default = false;
              description = "create folders from filesystem";
            };
            path = mkOption {
              type = path;
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
        assertion = addr != null;
        message = "Address missing";
      }
      {
        assertion = port != null;
        message = "Port missing";
      }
    ];

    services.grafana = {
      enable = true;

      inherit domain addr port;

      declarativePlugins = cfg.plugins;
      provision = {
        enable = true;
        datasources = let ds = cfg.datasources;
        in concatLists [
          (optional ds.prometheus.enable {
            name = "Prometheus";
            uid = "systemprom";
            type = "prometheus";
            url = let prom = config.services.prometheus;
            in "http://${prom.listenAddress}:${toString prom.port}";
            access = "proxy"; # "Server" in GUI
            editable = true; # see afterupdate
          })
        ];
        dashboards = let ds = cfg.datasources;
        in concatLists [
          (optional ds.prometheus.enable {
            name = "System";
            type = "file";
            folder = "system";
            updateIntervalSeconds = 10;
            disableDeletion = false;
            options = {
              path = ./grafana-resources/dashboards/system;
              foldersFromFilesStructure = false;
            };
          })
          (mapAttrsToList (name: val: {
            type = "file";
            inherit name;
            inherit (val) folder;
            updateIntervalSeconds = 10;
            disableDeletion = false;
            options = { inherit (val) path foldersFromFilesStructure; };
          }) cfg.dashboards)
        ];
      };
    };
  };
}
