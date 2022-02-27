{ config, lib, ... }:
let cfg = config.within.ssh;
in with lib; {
  options.within.ssh = { enable = mkEnableOption "SSH"; };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 25566 ];
      openFirewall = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };
  };
}
