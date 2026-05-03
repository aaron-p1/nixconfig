{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.graphics.dms-niri;
in
{
  options.within.graphics.dms-niri = {
    enable = mkEnableOption "DMS + Niri";
    greeter = {
      afterGpu = mkEnableOption "Start the greeter after the GPU is available";
    };
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

    services.udev.extraRules = mkIf cfg.greeter.afterGpu ''
      ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card1", TAG+="systemd"
    '';

    systemd.services.greetd = {
      serviceConfig.Type = lib.mkForce "simple";
      # make sure the gpu is available
      wants = mkIf cfg.greeter.afterGpu [ "dev-dri-card1.device" ];
      after = mkIf cfg.greeter.afterGpu [ "dev-dri-card1.device" ];
    };
  };
}
