{ config, lib, ... }:
let
  inherit (builtins) readFile fromJSON;
  inherit (lib) mkEnableOption mkOption types mkIf hasPrefix mapAttrs;

  cfg = config.within.syncthing;

  userHome = config.users.users."${cfg.user}".home;

  deviceIDFileContent = if config.within.enableEncryptedFileOptions then
    readFile cfg.deviceIDFile
  else
    "{}";
  deviceIDs = fromJSON deviceIDFileContent;

  folderDevices =
    lib.flatten (lib.mapAttrsToList (_: val: val.devices) cfg.folders);
  chosenDeviceIDs = lib.getAttrs folderDevices deviceIDs;

in {
  options.within.syncthing = {
    enable = mkEnableOption "syncthing";

    user = mkOption {
      type = types.str;
      description = "user to run syncthing as";
    };
    group = mkOption {
      type = types.str;
      description = "group to run syncthing as";
    };

    guiAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "address to run syncthing gui on";
    };

    deviceIDFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        path to file containing hostnames and device ids.
        JSON object with key "<hostname>" and value "<deviceID>"
      '';
    };

    folders = mkOption {
      default = { };
      description = "folders to sync with";
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          path = mkOption {
            type = types.str;
            description = "path to folder";
          };
          ignorePerms = mkOption {
            type = types.bool;
            default = false;
            description = "ignore permissions";
          };
          versioning = mkOption {
            default = null;
            description = "versioning";
            type = types.nullOr (types.submodule {
              options = {
                type = mkOption {
                  type =
                    types.enum [ "external" "simple" "staggered" "trashcan" ];
                  description = "type of versioning";
                };
                params = mkOption {
                  type = types.attrsOf types.str;
                  description = "versioning params";
                };
              };
            });
          };
          devices = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description =
              "devices to sync folder with. Devices must be defined in deviceIDFile";
          };
        };
      }));
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = userHome != "/var/empty";
        message = "User does not have home directory set";
      }
      {
        assertion = cfg.deviceIDFile != null;
        message = "No device IDs specified";
      }
      {
        assertion = hasPrefix "{" deviceIDFileContent;
        message = ''
          Device file does not start with {. If it's encrypted you could
          set within.enableEncryptedFileOptions to false in nixos config.
        ''; # }}
      }
    ];

    services.syncthing = {
      enable = true;
      inherit (cfg) user group guiAddress;
      dataDir = userHome;
      overrideDevices = true;
      overrideFolders = true;
      openDefaultPorts = true;
      settings = {
        devices = mapAttrs (_: val: { id = val; }) chosenDeviceIDs;
        folders = mapAttrs
          (key: val: { inherit (val) path ignorePerms versioning devices; })
          cfg.folders;

        gui.insecureSkipHostcheck = true;
      };
    };
  };
}
