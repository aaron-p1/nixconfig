{ config, pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ../../nixos/modules ];

  within.boot = {
    grub = true;
    efiMountPoint = "/boot/efi";
    supportedFilesystems = [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.useDHCP = false;
  networking.hostName = "aaron-laptop";
  networking.interfaces.enp3s0.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  within.swap.zram = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
