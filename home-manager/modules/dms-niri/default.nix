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
  _class = "homeManager";

  config = mkIf osCfg.enable {
    home = {
      file.".config/niri/config.kdl" = {
        source = ./config.kdl;
        force = true;
      };
      jsonPatch.".config/DankMaterialShell/settings.json".patch = ops: {
        # workspaceSwitcher
        showWorkspaceApps = true;
        groupWorkspaceApps = false;
        maxWorkspaceIcons = 8; # number window icons per workspace

        clockDateFormat = "ddd d. MMM";

        notificationOverlayEnabled = true; # enable notifications over full screen apps

        lockPamPath = "/etc/pam.d/dms-lock";
        lockPamExternallyManaged = true;

        barConfigs = ops.byField {
          id.default = {
            noBackground = true; # no widget background

            rightWidgets = ops.byField {
              id.memUsage = {
                showSwap = true;
                minimumWidth = true; # the "Force Padding" setting
              };
            };
          };
        };
      };
      packages = with pkgs; [
        playerctl
        brightnessctl
        xwayland-satellite
        kdePackages.dolphin
      ];
    };
  };
}
