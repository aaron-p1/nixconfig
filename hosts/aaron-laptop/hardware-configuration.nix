{ pkgs, config, lib, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];

    # boot partition space is limited
    loader.grub.configurationLimit = 8;

    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" "i915" ];
      kernelModules = [ ];

      # for luks fido2 device unlocking
      systemd = {
        enable = true;
        initrdBin = [ pkgs.kbd ];
        services.numlock = {
          description = "Enable NumLock in initrd TTYs";
          wantedBy = [ "cryptsetup.target" ];
          script = ''
            for tty in /dev/tty1; do
                /bin/setleds -D +num < "$tty";
            done
          '';
          serviceConfig.Type = "oneshot";
        };
      };
      luks.devices."cryptroot" = {
        device = "/dev/disk/by-uuid/83d040d2-0747-4ebc-864a-e39b017890cc";
        crypttabExtraOpts =
          [ "fido2-device=auto" "token-timeout=5s" "password-echo=no" ];
        allowDiscards = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/00359508-d793-4b9c-bbb9-247c0a7daa5b";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/00359508-d793-4b9c-bbb9-247c0a7daa5b";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/14f580c6-c72d-4706-a2b4-45922a7ceab5";
      fsType = "ext4";
    };

    "/boot/efi" = {
      device = "/dev/disk/by-uuid/5E20-1FEF";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}
