{ config, lib, pkgs, ... }:
let cfg = config.within.libreoffice;
in with lib; {
  options.within.libreoffice = { enable = mkEnableOption "Libre Office"; };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.libreoffice ];
  };
}
