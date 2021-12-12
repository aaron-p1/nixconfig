{ config, lib, ... }:
let cfg = config.within.zathura;
in with lib; {
  options.within.zathura = { enable = mkEnableOption "Zathura"; };

  config = mkIf cfg.enable { programs.zathura = { enable = true; }; };
}
