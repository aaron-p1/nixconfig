{ pkgs, config, ... }: {
  imports = [ ./hardware-configuration.nix ../../nixos/modules ];

  powerManagement.cpuFreqGovernor = "ondemand";

  # ../../nixos/modules/boot.nix
  within.boot = {
    grub = true;
    supportedFilesystems = [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware.enableAllFirmware = true;

  # NETWORKING
  networking.useDHCP = false;
  networking.hostName = "aaron-pc";
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ext4";
  };

  # ../../nixos/modules/swap.nix
  within.swap = {
    zram = true;
    file = 20;
  };

  hardware.nvidia.package = pkgs.local.nvidia_x11 config.boot.kernelPackages;
  services.xserver.videoDrivers = [ "nvidia" ];

  within.users.aaron = {
    u2fKeys = [
      # 1
      "Mb3DZGUsu4lhdja3HFiITo8bVdlYSSCisnNaXUukK0hLeIuHp7xHf7QFP/2VTwVei23pVNT9e3wE/eX1JJSkUQ==,Xu6hTKJhHgVU7Z3hIzqBhst3E0xW4J/MudMPLhruK4XFhIr74y69D9Z0aCsFZQ6YOcE0rk+4yTFSQhu/bR2S7A==,es256,+presence"
      # 2
      "LV/FPWrKyNQBfWhHDGxXVZkx/LDoW+EJKV65A28igjqqGKPGJ7PWWEQlNtumOy6b0C2WHYXo9MeSbqQboAs98w==,dSfmZDimcp1x3ttEM9sBCd7/fBE+EZ2aoboLx9GR/YIfJCyU/DWH7t+6vWQv8MzxL5mjZOjboGHoUrnCxCopvQ==,es256,+presence"
    ];

    resticBackup = {
      enable = true;
      paths = [ "/home/aaron/Documents" ];

      repository = "/mnt/data/backup/restic";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
