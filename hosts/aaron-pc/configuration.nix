{ config, pkgs, lib, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  powerManagement.cpuFreqGovernor = "ondemand";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableAllFirmware = true;
  boot.supportedFilesystems = [ "btrfs" ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  # NETWORKING 
  networking.useDHCP = false;
  networking.hostName = "aaron-pc";
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  # LOCALE
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # file creation not working in btrfs
  # https://github.com/NixOS/nixpkgs/issues/91986
  # create manually
  #
  # ${pkgs.coreutils}/bin/truncate -s 0 /swapfile
  # ${pkgs.e2fsprogs}/bin/chattr +C /swapfile
  # ${pkgs.btrfs-progs}/bin/btrfs property set /swapfile compression none
  swapDevices = [{
    device = "/swapfile";
    size = 1024 * 20;
  }];

  # ZSH COMPLETION
  environment.pathsToLink = [
    "/share/zsh"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

