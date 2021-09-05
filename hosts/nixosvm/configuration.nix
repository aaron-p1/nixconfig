{ config, pkgs, lib, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # GRUB
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.timeout = 1;
  boot.loader.grub.device = "/dev/vda";

  # NETWORKING 
  networking.hostName = "nixosvm";

  # LOCALE
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # ZSH COMPLETION
  environment.pathsToLink = [
    "/share/zsh"
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

