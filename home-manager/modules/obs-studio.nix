{ config, lib, pkgs, ... }:
let cfg = config.within.obs-studio;
in with lib; {
  options.within.obs-studio = { enable = mkEnableOption "OBS Studio"; };

  config = mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-nvfbc ];
    };
  };
}
