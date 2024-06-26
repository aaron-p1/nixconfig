{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.locale;
in {
  options.within.locale = { enable = mkEnableOption "my locale config"; };

  config = mkIf cfg.enable {
    time.timeZone = "Europe/Berlin";

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_CTYPE = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
        LC_COLLATE = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_ADDRESS = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
      };
    };

    console = {
      font = "Lat2-Terminus16";
      keyMap = "de";
    };
  };
}
