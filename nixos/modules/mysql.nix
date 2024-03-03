{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.mysql;
in {
  options.within.mysql = { enable = mkEnableOption "MySQL"; };

  config = mkIf cfg.enable {
    services.mysql = {
      enable = true;

      package = pkgs.mariadb;

      settings.mysqld.skip_networking = true;
    };
  };
}
