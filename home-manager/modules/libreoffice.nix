{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.libreoffice;
in {
  options.within.libreoffice = { enable = mkEnableOption "Libre Office"; };

  config = mkIf cfg.enable { home.packages = [ pkgs.libreoffice ]; };
}
