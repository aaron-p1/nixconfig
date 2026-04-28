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
        onChange = # bash
          ''
            touch /home/aaron/.config/niri/dynamic.kdl
            mkdir -p /home/aaron/.config/niri/dms
            touch /home/aaron/.config/niri/dms/{colors,layout,alttab,binds,cursor,outputs,windowrules,wpblur}.kdl
          '';
      };
      packages = with pkgs; [
        playerctl
        brightnessctl
        xwayland-satellite
        nautilus
      ];

      pointerCursor = {
        enable = true;
        package = pkgs.kdePackages.breeze;
        name = "breeze_cursors";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
    };
  };
}
