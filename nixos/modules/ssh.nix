{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.ssh;
in
{
  options.within.ssh = {
    enable = mkEnableOption "SSH";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 25566 ];
      openFirewall = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        Macs = [
          # Default
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
          # iOS Shortcuts
          "hmac-sha2-512"
        ];
      };
    };
  };
}
