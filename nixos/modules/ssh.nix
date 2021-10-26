{ ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 25566 ];
    openFirewall = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };
}
