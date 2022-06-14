{ config, lib, ... }:
let
  cfg = config.within.syncthing;

  userHome = config.users.users."${cfg.user}".home;

  deviceIDFileContent = if config.within.enableEncryptedFileOptions then
    builtins.readFile cfg.deviceIDFile
  else
    "{}";
  deviceIDs = builtins.fromJSON deviceIDFileContent;
  chosenDeviceIDs = lib.getAttrs cfg.devices deviceIDs;

in with lib; {
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

    devices = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "hostnames of devices to sync with";
    };
    deviceIDFile = mkOption {
      type = with types; nullOr path;
      default = null;
      description = ''
        path to file containing hostnames and device ids.
        JSON object with key "<hostname>" and value "<deviceID>"
      '';
    };

    folders = mkOption {
      default = [ ];
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
            type = with types;
              nullOr (submodule {
                options = {
                  type = mkOption {
                    type = enum [ "external" "simple" "staggered" "trashcan" ];
                    description = "type of versioning";
                  };
                  params = mkOption {
                    type = attrsOf str;
                    description = "versioning params";
                  };
                };
              });
          };
          devices = mkOption {
            type = with types; listOf str;
            default = [ ];
            description =
              "devices to sync folder with. Must be contained in devices";
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
      extraOptions = { gui.insecureSkipHostcheck = true; };
      devices = mapAttrs (_: val: { id = val; }) chosenDeviceIDs;
      folders = mapAttrs
        (key: val: { inherit (val) path ignorePerms versioning devices; })
        cfg.folders;
    };
  };
}
