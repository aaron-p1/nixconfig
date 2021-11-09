{ ... }:
{
  networking.useDHCP = false; # deprecated

  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  networking.networkmanager = {
    enable = true;
    dns = "dnsmasq";
  };

  environment.etc."NetworkManager/dnsmasq.d/local" = {
    text = ''
      address=/exo/127.32.0.2
    '';
  };

  environment.etc."NetworkManager/dnsmasq.d/network" = {
    text = ''
      address=/public-server/192.168.178.26
    '';
  };
}
