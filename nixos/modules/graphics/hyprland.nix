{ config, lib, ... }:
let cfg = config.within.graphics.hyprland;
in with lib; {
  options.within.graphics.hyprland = {
    enable = mkEnableOption "Hyprland";

    nvidia = mkEnableOption "Nvidia support";
  };

  # needs hyprland flake
  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;

      nvidiaPatches = cfg.nvidia;
    };
  };
}
