{ modulesPath, ... }:
{
  _class = "nixos";

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    kernelModules = [ "kvm-intel" ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/6fe51b19-3d2b-4340-b057-4b82f1fa990a";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/6fe51b19-3d2b-4340-b057-4b82f1fa990a";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/6fe51b19-3d2b-4340-b057-4b82f1fa990a";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/963B-321C";
      fsType = "vfat";
    };
  };
}
