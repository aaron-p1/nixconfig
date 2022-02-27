{ pkgs, config, ... }: {
  imports = [ ./hardware-configuration.nix ];

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

  hardware.nvidia.package = pkgs.local.nvidia_x11 config.boot.kernelPackages;

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

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/swapfile";
    size = 1024 * 20;
    priority = 1;
  }];

  # compressed ram swap max 50%
  zramSwap = { enable = true; };

  # ZSH COMPLETION
  environment.pathsToLink = [ "/share/zsh" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
