{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.zathura;
in {
  options.within.zathura = { enable = mkEnableOption "Zathura"; };

  config = mkIf cfg.enable { programs.zathura = { enable = true; }; };
}
