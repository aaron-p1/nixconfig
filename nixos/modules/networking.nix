{ pkgs, ... }:
{
  networking.useDHCP = false; # deprecated

  networking.networkmanager.enable = true;
}
