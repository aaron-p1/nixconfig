{ config, lib, ... }:
let cfg = config.within.graphics.xserver;
in with lib; {
  options.within.graphics.xserver = { enable = mkEnableOption "XServer"; };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      xkb = {
        layout = "de";

        options = builtins.concatStringsSep "," [
          "terminate:ctrl_alt_bksp"
          "caps:escape"
          "compose:sclk"
        ];
      };

      libinput = {
        enable = true;
        mouse = { accelProfile = "flat"; };
      };
    };
  };
}
