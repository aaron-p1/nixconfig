{ config, lib, pkgs, ... }:
let cfg = config.within.boot;
in with lib; {
  options.within.boot = {
    grub = mkEnableOption "Grub bootloader";
    efiMountPoint = mkOption {
      type = types.str;
      default = "/boot";
      description = "Dir to mount efi on";
    };
    supportedFilesystems = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "Supported filesystems";
    };
    kernelPackages = mkOption {
      type = types.unspecified;
      default = pkgs.linuxPackages;
      description = "Kernel Packages";
    };
  };

  config = mkIf cfg.grub {
    boot = {
      inherit (cfg) kernelPackages supportedFilesystems;
      loader = {
        timeout = 2;
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = cfg.efiMountPoint;
        };
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
        };
      };
    };
  };
}
