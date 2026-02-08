{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/modules
  ];

  powerManagement.cpuFreqGovernor = "ondemand";

  # NETWORKING
  networking = {
    useDHCP = false;
    hostName = "aaron-pc";
    interfaces = {
      enp4s0.useDHCP = true;
    };
  };

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "ext4";
  };

  boot.kernelParams = lib.mkIf (config.specialisation != { }) [
    "retbleed=stuff"
  ];

  specialisation.no-mitigations.configuration.boot.kernelParams = [
    "mitigations=off"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    nvidiaSettings = false;
    open = false;
  };

  within = {
    # ../../nixos/modules/boot.nix
    boot = {
      grub = true;
      kernelPackages = pkgs.linuxPackages_latest;
    };

    # ../../nixos/modules/swap.nix
    swap.file = 32;

    syncthing.folders = {
      thl.devices = [ "aaron-laptop" ];
      work.devices = [ "aaron-laptop" ];
    };

    steam.enable = true;

    containers.enableNvidia = true;

    responsiveness = {
      enable = true;

      system.nix-daemon.resources = {
        cpu.weight = 20;
        io.weight = 20;
      };
      user = {
        resources = {
          cpu.weight = 1000;
          io.weight = 1000;
        };

        session.resources = {
          cpu.weight = 1000;
          memory.low = "256M";
          io.weight = 1000;
        };
        app.firefox.resources = {
          cpu.weight = 1000;
          memory.low = "256M";
          io.weight = 1000;
        };
      };
    };
  };

  services.restic.backups.aaron-documents = {
    paths = [ "/home/aaron/Documents" ];
    repository = "/mnt/data/backup/restic";
    initialize = true;
    user = "aaron";
    passwordFile = "/etc/secrets/restic_local";
    timerConfig = {
      OnCalendar = "12,21:00";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-within 7d"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 75"
    ];
  };

  services.mullvad-vpn.enable = false;

  programs = {
    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  environment.systemPackages = with pkgs; [ mangohud ];

  virtualisation.libvirtd = {
    enable = false;
    qemu = {
      package = pkgs.qemu_kvm;
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
