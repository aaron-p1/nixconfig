{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.graphics.gdm;
in
{
  options.within.graphics.gdm = {
    enable = mkEnableOption "GDM";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm = {
        enable = true;
      };
    };
  };
}
