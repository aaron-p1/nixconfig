{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.audio;
in
{
  options.within.audio = {
    pipewire.enable = mkEnableOption "pipewire";
  };

  config = mkIf cfg.pipewire.enable {
    security.rtkit.enable = true; # optional but recommended

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      #jack.enable = true; # for jack applications
    };
  };
}
