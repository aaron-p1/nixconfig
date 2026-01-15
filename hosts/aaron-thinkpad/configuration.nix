{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixos/modules
  ];

  networking = {
    useDHCP = false;
    hostName = "aaron-thinkpad";
    interfaces.wlp0s20f3.useDHCP = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.extraPackages = [ pkgs.intel-media-driver ];
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      nvidiaSettings = false;
      prime = {
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
  };

  within = {
    boot = {
      grub = true;
      efiMountPoint = "/boot";
      kernelPackages = pkgs.linuxPackages_latest;
    };

    swap.file = 32;

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
          memory.low = "2G";
          io.weight = 1000;
        };
        app.firefox.resources = {
          cpu.weight = 1000;
          memory.low = "2G";
          io.weight = 1000;
        };
      };
    };
  };

  services.nginx.virtualHosts."exo-wp-to-exo.dev.home.arpa".locations."/" = {
    proxyPass = "http://app.exo.dev.home.arpa";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
