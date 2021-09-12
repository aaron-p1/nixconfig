{ pkgs, inputs, ... }:
{
  imports = [
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/networking.nix
    ../modules/ssh.nix
    ../modules/essential_packages.nix
    ../modules/users/aaron.nix
    ../modules/sddm.nix
    ../modules/plasma.nix
    ../modules/pipewire.nix
  ];

}
