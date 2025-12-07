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
      wlp7s0.useDHCP = true;
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
    package = config.boot.kernelPackages.nvidiaPackages.latest;
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

    users.aaron = {
      u2fKeys = [
        # 1
        "hMb1Haep8BdpUGM/wGAnHuhKbZE+jQ9T6LjQZiChafEHAERJCDgDZhfCpA9/zw7fJSai0HRtvqFxcNZpHkroiA==,rzWcdmxnQy2bPhxifpLLK2K4cL+F3crEc2BuvlCPM51Dsq5N9VawvFxo9HPv1bHRqvYtq+/HlNM47ZtwlijArw==,es256,+presence"
        # 2
        "nuf7Ig6OU1qW3Q7srl4JfD5j3yED6ai0TeMV7N9L3maVMVcx8gbmw/nJgefpTiDWOp27I9IkvMB7S8cWL2zr3Q==,wAoubro0eh+hziuSt2Me8IwyWgpCgZq4dv95So+gRDGSIhDJB5VGYT5XljNUJRRD7jXxVMNMh65kAXeIuO7Mqw==,es256,+presence"
      ];
    };

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

  services.mullvad-vpn.enable = true;

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
