{ config, lib, ... }:
let cfg = config.within.samba;
in with lib; {
  options.within.samba = { enable = mkEnableOption "Samba"; };

  config = mkIf cfg.enable {
    services.samba = {
      enable = true;

      extraConfig = ''
        load printers = no
        vfs objects = fruit streams_xattr
      '';

      openFirewall = true;

      # for users set: smbpasswd -a <user>
      shares = {
        homeShare = {
          path = "%H/Share";
          comment = "Separate user directories";
          writable = "yes";
        };
      };
    };
  };
}
