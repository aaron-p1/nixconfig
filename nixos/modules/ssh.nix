{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 25566 ];
    permitRootLogin = "no";
  };
}
