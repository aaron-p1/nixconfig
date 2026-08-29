{
  config,
  pkgs,
  lib,
  ...
}:
{
  _class = "nixos";

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

  boot.kernelParams = lib.mkIf (config.specialisation != { }) [
    "retbleed=stuff"
  ];

  specialisation.no-mitigations.configuration.boot.kernelParams = [
    "mitigations=off"
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    branch = "legacy_580";
    modesetting.enable = true;
    nvidiaSettings = false;
    open = false;
  };

  within = {
    # ../../nixos/modules/boot.nix
    boot.grub = true;

    # ../../nixos/modules/swap.nix
    swap.file = 32;

    steam.enable = true;

    containers.enableNvidia = false;

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

    graphics.dms-niri.greeter = {
      afterGpu = true;
      output = {
        name = "DVI-I-1";
        mode = "1920x1080@144.001";
      };
    };
  };

  services = {
    mullvad-vpn.enable = false;

    scx = {
      enable = true;
      scheduler = "scx_lavd";
      # scheduler = "scx_bpfland";
    };
  };

  programs = {
    gamemode.enable = true;
    gamescope = {
      enable = true;
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
