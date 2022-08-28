{ config, lib, options, pkgs, ... }:
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

          resticBackups = options.services.restic.backups;
        };
      }));
    default = { };
    description = "User config";
  };

  config = let
    u2fText = concatStringsSep "\n"
      (mapAttrsToList (n: v: concatStringsSep ":" ([ n ] ++ v.u2fKeys))
        (filterAttrs (n: v: length v.u2fKeys > 0) cfg));

    anyRestic = any (v: attrNames v.resticBackups != [ ]) (attrValues cfg);
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

    services.restic.backups = let
      backupsNestedList = mapAttrsToList (userName: userConfig:
        mapAttrsToList (backupName: backupConfig: {
          name = "${userName}-${backupName}";
          value = backupConfig // { user = userName; };
        }) userConfig.resticBackups) cfg;
    in listToAttrs (flatten backupsNestedList);

    environment.systemPackages = optional anyRestic pkgs.restic;
  };
}
