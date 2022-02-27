{ config, lib, pkgs, ... }:
let cfg = config.within.users;
in with lib; {
  options.within.users = mkOption {
    type = with types;
      attrsOf (submodule ({ name, config, ... }: {
        options = {
          uid = mkOption {
            type = types.int;
            description = "uid";
          };
          sshKeys = mkOption {
            type = with types; listOf str;
            default = [ ];
            description = "SSH Keys";
          };
          u2fKeys = mkOption {
            type = with types; listOf str;
            default = [ ];
            description = "U2F Keys";
          };

          resticBackup = {
            enable = mkEnableOption "Restic Backup";

            paths = mkOption {
              type = with types; listOf str;
              description = "Restic backup paths";
            };

            repository = mkOption {
              type = types.str;
              description = "Restic repository";
            };
          };
        };
      }));
    default = { };
    description = "User config";
  };

  config = let
    u2fText = concatStringsSep "\n"
      (mapAttrsToList (n: v: concatStringsSep ":" ([ n ] ++ v.u2fKeys))
        (filterAttrs (n: v: length v.u2fKeys > 0) cfg));

    anyRestic = any (v: v.resticBackup.enable) (attrValues cfg);
  in {
    users.users = mapAttrs' (name: config:
      nameValuePair name {
        inherit (config) uid;
        isNormalUser = true;
        createHome = true;
        extraGroups = [ "wheel" "networkmanager" ];
        shell = pkgs.zsh;

        autoSubUidGidRange = true; # for containers

        openssh.authorizedKeys.keys = config.sshKeys;
      }) cfg;

    environment.etc =
      mkMerge [ (mkIf (u2fText != "") { "u2f-mappings".text = u2fText; }) ];

    services.restic.backups = mapAttrs' (name: config:
      nameValuePair "localbackup-${name}" {
        user = name;
        initialize = true;
        passwordFile = "/etc/secrets/restic_local";
        inherit (config.resticBackup) paths repository;
        timerConfig = {
          OnCalendar =
            "0/3:00"; # every 3 hours (systemd-analyze --iterations=5 "0/3:00")
        };
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];
      }) (filterAttrs (n: v: v.resticBackup.enable) cfg);

    environment.systemPackages = optional anyRestic pkgs.restic;
  };
}
