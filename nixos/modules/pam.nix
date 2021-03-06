{ config, lib, ... }:
let cfg = config.within.pam;
in with lib; {
  options.within.pam = {
    u2f = {
      enable = mkEnableOption "pamu2f mappings";
    };
  };

  config = mkIf cfg.u2f.enable {
    security.pam.u2f = {
      enable = true;
      cue = true;
      authFile = "/etc/u2f-mappings";
    };

    environment.etc."u2f-mappings" = {
      enable = true;
      text = "";
    };
  };
}
