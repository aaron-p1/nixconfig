{ pkgs, ... }:
{
  networking.useDHCP = false; # deprecated
  networking.interfaces.enp1s0.useDHCP = true;
}
