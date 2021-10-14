{ pkgs, inputs, ... }:
{
  services.samba = {
    enable = true;

    extraConfig = builtins.concatStringsSep "\n" [
      "load printers = no"
      "vfs objects = fruit streams_xattr"
    ];


    # for users set: smbpasswd -a <user>
    shares = {
      homeShare = {
        path = "%H/Share";
        comment = "Separate user directories";
        writable = "yes";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 445 139 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
