{ pkgs, inputs, ... }:
{
  imports = [
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/networking.nix
    ../modules/ssh.nix
    ../modules/essential_packages.nix
    ../modules/users/aaron.nix
    ../modules/pamu2f.nix
    ../modules/xserver.nix
    ../modules/sddm.nix
    ../modules/plasma.nix
    ../modules/pipewire.nix
    ../modules/bluetooth.nix
    ../modules/dconf.nix
    ../modules/samba.nix

    ../modules/steam.nix

    # cli
    ../modules/containers.nix
    ../modules/podman.nix
  ];
}
