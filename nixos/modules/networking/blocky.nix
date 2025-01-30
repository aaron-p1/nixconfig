{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.within.networking.blocky;
in {
  options.within.networking.blocky =
    let inherit (types) str nullOr listOf path attrsOf bool;
    in {
      enable = mkEnableOption "blocky";

      ip = mkOption {
        type = str;
        default = "127.0.0.1";
        description = "IPv4 to run blocky on";
      };

      httpPort = mkOption {
        type = nullOr str;
        default = null;
        description = "http address to listen on";
      };

      bootstrapDns = mkOption {
        type = str;
        default = "9.9.9.9";
        description = "used for resolving nameservers and blockLists";
      };

      nameservers = mkOption {
        type = listOf str;
        default = config.networking.nameservers;
        description = "nameservers";
      };

      blockLists = mkOption {
        type = listOf str;
        default = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn/hosts"
        ];
        description = "lists to enable blocking on";
      };
      blockListFile = mkOption {
        type = nullOr path;
        default = null;
        description = "list of paths to blocklist file";
      };

      mapDomains = mkOption {
        type = attrsOf str;
        default = { };
        description = "domains to ip mappings";
      };

      prometheus = mkOption {
        type = bool;
        default = false;
        description = "enable prometheus monitoring. Needs httpPort";
      };
    };

  config = let
    inherit (lib) optional;

    fileToUnlock = cfg.blockListFile;
    autoUnlockStateDir = "dns-auto-unblock";
    autoUnlockDenyListFileName = "denylist.txt";
    autoUnlockDenyListFilePath =
      "/var/lib/${autoUnlockStateDir}/${autoUnlockDenyListFileName}";

    blockLists = cfg.blockLists
      ++ (optional (cfg.blockListFile != null) autoUnlockDenyListFilePath);
  in mkIf cfg.enable {
    assertions = [{
      assertion = cfg.prometheus -> cfg.httpPort != null;
      message = "httpPort needed if prometheus is enabled";
    }];

    services.blocky = {
      enable = true;

      # https://0xerr0r.github.io/blocky/configuration
      settings = {
        inherit (cfg) bootstrapDns httpPort;
        ports.dns = "${cfg.ip}:53";
        upstreams.groups.default = cfg.nameservers;
        customDNS.mapping = cfg.mapDomains;
        blocking = {
          denylists.default = blockLists;
          clientGroupsBlock.default = [ "default" ];
          loading.downloads = {
            attempts = 0;
            cooldown = "4s";
          };
        };
        log.level = "warn";
        prometheus.enable = cfg.prometheus;
      };
    };

    systemd = mkIf (cfg.blockListFile != null) {
      services.dns-auto-unblock = {
        description = "Auto unblock domains on a certain day";
        startAt = "daily";
        wantedBy = [ "blocky.service" ];
        serviceConfig = {
          Type = "oneshot";
          # for restarting when changed
          RemainAfterExit = true;
          StateDirectory = autoUnlockStateDir;
          ExecStartPost = "systemctl try-reload-or-restart blocky.service";
        };
        script = ''
          DAY_OF_WEEK=$(date +%u)
          DAY_OF_MONTH=$(date +%d)

          # every first Saturday of the month
          if [[ $DAY_OF_WEEK -eq 6 && $DAY_OF_MONTH -le 7 ]]; then
            echo "Unblocking domains"
            touch $STATE_DIRECTORY/tmp.txt
          else
            echo "Blocking domains"
            ln -s ${fileToUnlock} $STATE_DIRECTORY/tmp.txt
          fi

          mv $STATE_DIRECTORY/tmp.txt $STATE_DIRECTORY/${autoUnlockDenyListFileName}
        '';
      };
      timers.dns-auto-unblock.timerConfig.Persistent = true;
    };
  };
}
