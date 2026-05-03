{
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;

  osCfg = osConfig.within.graphics.dms-niri;
in
{
  config = mkIf osCfg.enable {
    home = {
      file.".config/niri/config.kdl" = {
        source = ./config.kdl;
        force = true;
      };
      packages = with pkgs; [
        playerctl
        brightnessctl
        xwayland-satellite
        nautilus
      ];
    };
  };
}
