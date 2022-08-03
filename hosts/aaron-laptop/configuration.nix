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

  within.networking.v6 = {
    loopbackPrefix = "fdfd:3ea0:fd08:44cc";
    loopbackPrefixLength = 64;
  };

  within.swap.file = 20;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  specialisation.use-nvidia-gpu.configuration = {
    hardware.nvidia = {
      modesetting.enable = true;
      prime = {
        offload.enable = false;
        sync.enable = true;
      };
    };
  };

  within = {
    users.aaron.u2fKeys = [
      # 1
      "K75FjUADd0jxHJxt1mSt1l9SaMZytdusDhBWHreUHkZF2t3NLKoSMswyLgaNDktrc5OdCNuQvc5ZF0w+Jyk5Jw==,KAoLBV0lY/dTByVVLUshVjIZknJuolefxUG68FcVD86kU+mvXc7qh5vRSXE56QL6zXQ0yJWnrqcXp0hZnsUkLQ==,es256,+presence"
      # 2
      "11iNbdbRK5qw71GUhRYJ+/EQW1T/GU/X3NMjpcMHuXqkybKZ5Qa74dmlR8iXIb/6+SXwTno1oVAAJHm5IJDtvA==,AYID8itmW0xAcd+9ZCl4pHVuTQwB7Npk4XhmqVP5KFMuDfaDOG4aYi1E+p62wPdpxc6xPTPx6ZwU23jGPtutPA==,es256,+presence"
    ];

    syncthing.folders = {
      thl.devices = [ "aaron-pc" ];
      work.devices = [ "aaron-pc" ];
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = { package = pkgs.qemu_kvm; };
  };

  programs.chromium.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
