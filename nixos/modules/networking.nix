{ pkgs, ... }:
{
  networking.useDHCP = false; # deprecated

  networking.networkmanager.enable = true;

  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
