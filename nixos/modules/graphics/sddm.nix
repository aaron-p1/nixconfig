{ config, lib, ... }:
let
  cfg = config.within.graphics.sddm;
in
with lib; {
  options.within.graphics.sddm = {
    enable = mkEnableOption "sddm";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      displayManager.sddm = {
        enable = true;
      };
    };
  };
}
