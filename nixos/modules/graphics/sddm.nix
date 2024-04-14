{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.graphics.sddm;
in {
  options.within.graphics.sddm = { enable = mkEnableOption "sddm"; };

  config = mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };
  };
}
