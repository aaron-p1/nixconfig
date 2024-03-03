{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.bluetooth;
in {
  options.within.bluetooth = { enable = mkEnableOption "Bluetooth"; };

  config = mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    services.blueman.enable = false;
  };
}
