{ config, lib, ... }:
let
  cfg = config.within.locale;
in
with lib; {
  options.within.locale = {
    enable = mkEnableOption "my locale config";
  };

  config = mkIf cfg.enable {
    time.timeZone = "Europe/Berlin";

    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };
  };
}
