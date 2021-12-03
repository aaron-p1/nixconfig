{ config, lib, ... }:
let
  cfg = config.within.bluetooth;
in
with lib; {
  options.within.bluetooth = {
    enable = mkEnableOption "Bluetooth";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    services.blueman.enable = false;
  };
}
