{ config, lib, ... }:
let
  cfg = config.within.pam;
in
with lib; {
  options.within.pam = {
    u2f = {
      enable = mkEnableOption "pamu2f mappings";
      appId = mkOption {
        type = types.str;
        default = "nixauth";
        description = "appid argument for pamu2f";
      };
    };
  };

  config = mkIf cfg.u2f.enable {
    security.pam.u2f = {
      enable = true;
      cue = true;
      authFile = "/etc/u2f-mappings";
      inherit (cfg.u2f) appId;
    };

    environment.etc."u2f-mappings" = {
      enable = true;
      text = "";
    };
  };
}
