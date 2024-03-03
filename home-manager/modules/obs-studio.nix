{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.obs-studio;
in {
  options.within.obs-studio = { enable = mkEnableOption "OBS Studio"; };

  config = mkIf cfg.enable { programs.obs-studio = { enable = true; }; };
}
