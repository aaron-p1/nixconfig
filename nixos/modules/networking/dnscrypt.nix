{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption mkIf;
  inherit (lib.types) attrsOf str;

  ncfg = config.within.networking;
  cfg = ncfg.dnscrypt;

  dnsFilteringStateDir = "dns-filtering";
  publicBlockListFileName = "public-blocklist.txt";

  fileToUnblock = ../../../secrets/inline-secrets/blocked-domains.txt;

  finalBlockListFileName = "final-blocklist.txt";
  finalBlockList = "/var/lib/${dnsFilteringStateDir}/${finalBlockListFileName}";
in
{
  options.within.networking.dnscrypt = {
    enable = mkEnableOption "Dnscrypt";

    cloak = mkOption {
      type = attrsOf str;
      default = { };
      description = "dnscrypt cloaking rules";
    };
  };

  config = mkIf cfg.enable {
    within.networking.bindAddrsV4.dnscrypt = "127.0.0.1:53";

    networking = {
      nameservers = [ "127.0.0.1" ];
      networkmanager.dns = "none";
      resolvconf.useLocalResolver = true;
    };

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        listen_addresses = [ ncfg.bindAddrsV4.dnscrypt ];
        ipv6_servers = true;
        require_dnssec = true;

        server_names = [ "quad9-doh-ip4-port443-filter-pri" ];

        blocked_names.blocked_names_file = finalBlockList;

        forwarding_rules = pkgs.writeText "forwarding-rules.txt" ''
          local     $DHCP
          internal  $DHCP
          intranet  $DHCP
          fritz.box $DHCP

          ts.net      100.100.100.100
          home.arpa   100.100.100.100
          home-server 100.100.100.100
        '';

        cloaking_rules =
          let
            inherit (lib) mapAttrsToList concatStringsSep;

            hostLines = mapAttrsToList (src: dst: "${src} ${dst}") cfg.cloak;
          in
          pkgs.writeText "cloaking-rules.txt" ''
            ${concatStringsSep "\n" hostLines}
          '';
      };
    };

    systemd = {
      services = {
        dnscrypt-proxy2.serviceConfig = {
          # wait for sd_notify ready from service before being considered started
          Type = "notify";
          # needed for sd_notify
          RestrictAddressFamilies = [ "AF_UNIX" ];
        };

        dns-gen-block-list = {
          description = "Generate block list for dnscrypt-proxy2";
          startAt = "weekly";
          wants = [ "network-online.target" ];
          after = [
            "network-online.target"
            "dnscrypt-proxy2.service"
          ];
          serviceConfig = {
            RemainAfterExit = true;
            Type = "oneshot";
            StateDirectory = dnsFilteringStateDir;
            ExecStartPost = "systemctl --no-block restart dns-auto-unblock.service";
          };
          script =
            let
              inherit (builtins) readFile;

              originalScriptPath =
                pkgs.dnscrypt-proxy2.src + "/utils/generate-domains-blocklist/generate-domains-blocklist.py";
              genBlockList = pkgs.writers.writePython3 "gen-block-list" { doCheck = false; } (
                readFile originalScriptPath
              );

              # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/utils/generate-domains-blocklist/domains-blocklist.conf
              blocklists = pkgs.writeText "blocklist.conf" ''
                # Peter Lowe's Ad and tracking server list
                https://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml

                # BarbBlock list (spurious and invalid DMCA takedowns)
                https://paulgb.github.io/BarbBlock/blacklists/domain-list.txt

                # NoTracking's list - blocking ads, trackers and other online garbage
                https://raw.githubusercontent.com/notracking/hosts-blocklists/master/dnscrypt-proxy/dnscrypt-proxy.blacklist.txt

                # NextDNS CNAME cloaking list
                https://raw.githubusercontent.com/nextdns/cname-cloaking-blocklist/master/domains

                # Geoffrey Frogeye's block list of first-party trackers - https://hostfiles.frogeye.fr/
                https://hostfiles.frogeye.fr/firstparty-trackers.txt

                # A list of adserving and tracking sites maintained by @lightswitch05
                https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt

                # A list of adserving and tracking sites maintained by @anudeepND
                https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt

                # OISD.NL (smaller subset) - Blocks ads, phishing, malware, tracking and more. Tries to minimize false positives.
                https://dblw.oisd.nl/basic/
              '';

              allowList = pkgs.writeText "allowlist.conf" ''
                sentry.io
                sentry-cdn.com
              '';
            in
            ''
              ${genBlockList} \
                --config ${blocklists} \
                --time-restricted "" \
                --allowlist ${allowList} \
                --output-file $STATE_DIRECTORY/${publicBlockListFileName}
            '';
        };

        dns-auto-unblock = {
          description = "Auto unblock domains on a certain day";
          startAt = "daily";
          wantedBy = [ "dnscrypt-proxy2.service" ];
          after = [ "dns-gen-block-list.service" ];
          serviceConfig = {
            Type = "oneshot";
            # for restarting when changed
            RemainAfterExit = true;
            StateDirectory = dnsFilteringStateDir;
            ExecStartPost = "systemctl try-reload-or-restart dnscrypt-proxy2.service";
          };
          script = ''
            touch $STATE_DIRECTORY/${finalBlockListFileName}

            PUBLIC_BLOCK_LIST_FILE=$STATE_DIRECTORY/${publicBlockListFileName}
            TMP_COMBINED=$STATE_DIRECTORY/tmp-combined.txt

            if [[ ! -f $PUBLIC_BLOCK_LIST_FILE ]]; then
              systemctl restart dns-gen-block-list.service
            fi

            [[ ! -f $PUBLIC_BLOCK_LIST_FILE ]] && touch $PUBLIC_BLOCK_LIST_FILE

            DAY_OF_WEEK=$(date +%u)
            DAY_OF_MONTH=$(date +%d)

            cat $PUBLIC_BLOCK_LIST_FILE > $TMP_COMBINED

            # every first Saturday of the month
            if [[ ! ( $DAY_OF_WEEK -eq 6 && $DAY_OF_MONTH -le 7 ) ]]; then
              echo "Blocking domains"
              cat ${fileToUnblock} >> $TMP_COMBINED
            fi

            mv $TMP_COMBINED $STATE_DIRECTORY/${finalBlockListFileName}
          '';
        };
      };
      timers = {
        dns-gen-block-list.timerConfig.Persistent = true;
        dns-auto-unblock.timerConfig.Persistent = true;
      };
    };
  };
}
