{ config, lib, ... }:
let cfg = config.within.graphics.gdm;
in with lib; {
  options.within.graphics.gdm = { enable = mkEnableOption "GDM"; };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm = { enable = true; };
    };
  };
}
