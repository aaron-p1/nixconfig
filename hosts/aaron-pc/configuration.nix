{ pkgs, config, ... }: {
  imports = [ ./hardware-configuration.nix ../../nixos/modules ];

  powerManagement.cpuFreqGovernor = "ondemand";

  # ../../nixos/modules/boot.nix
  within.boot = {
    grub = true;
    supportedFilesystems = [ "btrfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # NETWORKING
  networking.useDHCP = false;
  networking.hostName = "aaron-pc";
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp7s0.useDHCP = true;

  networking.firewall.allowedTCPPorts = [ 19000 ];

  within.networking.v6 = {
    loopbackPrefix = "fd70:a008:85df:ffb2";
    loopbackPrefixLength = 64;
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ext4";
  };

  # ../../nixos/modules/swap.nix
  within.swap.file = 20;

  hardware.nvidia.package =
    pkgs.local.nvidia-patched config.boot.kernelPackages.nvidiaPackages.stable;
  services.xserver.videoDrivers = [ "nvidia" ];

  within = {
    users.aaron = {
      u2fKeys = [
        # 1
        "hMb1Haep8BdpUGM/wGAnHuhKbZE+jQ9T6LjQZiChafEHAERJCDgDZhfCpA9/zw7fJSai0HRtvqFxcNZpHkroiA==,rzWcdmxnQy2bPhxifpLLK2K4cL+F3crEc2BuvlCPM51Dsq5N9VawvFxo9HPv1bHRqvYtq+/HlNM47ZtwlijArw==,es256,+presence"
        # 2
        "nuf7Ig6OU1qW3Q7srl4JfD5j3yED6ai0TeMV7N9L3maVMVcx8gbmw/nJgefpTiDWOp27I9IkvMB7S8cWL2zr3Q==,wAoubro0eh+hziuSt2Me8IwyWgpCgZq4dv95So+gRDGSIhDJB5VGYT5XljNUJRRD7jXxVMNMh65kAXeIuO7Mqw==,es256,+presence"
      ];

      resticBackups = {
        documents = {
          paths = [ "/home/aaron/Documents" ];
          repository = "/mnt/data/backup/restic";
          initialize = true;
          passwordFile = "/etc/secrets/restic_local";
          timerConfig = {
            OnCalendar =
              "0/3:00"; # every 3 hours (systemd-analyze --iterations=5 "0/3:00")
          };
          pruneOpts = [
            "--keep-hourly 24"
            "--keep-daily 7"
            "--keep-weekly 5"
            "--keep-monthly 12"
            "--keep-yearly 75"
          ];
        };
      };
    };

    syncthing.folders = {
      thl.devices = [ "aaron-laptop" ];
      work.devices = [ "aaron-laptop" ];
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu = { package = pkgs.qemu_kvm; };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
