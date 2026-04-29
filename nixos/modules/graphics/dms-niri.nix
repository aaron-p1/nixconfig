{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.graphics.dms-niri;
in
{
  options.within.graphics.dms-niri = {
    enable = mkEnableOption "DMS + Niri";
  };

  config = mkIf cfg.enable {
    services = {
      displayManager.dms-greeter = {
        enable = true;
        configHome = "/home/aaron";
        compositor.name = "niri";
      };
      logind.settings.Login.HandlePowerKey = "ignore";
      upower.enable = true;
    };

    programs = {
      dms-shell = {
        enable = true;

        systemd = {
          enable = true;
          restartIfChanged = false;
        };

        enableSystemMonitoring = true;
        enableVPN = true;
        enableDynamicTheming = true;
        enableAudioWavelength = false;
        enableCalendarEvents = false;
        enableClipboardPaste = true;
      };

      niri.enable = true;
    };
  };
}
