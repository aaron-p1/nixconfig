{ config, lib, pkgs, ... }:
let cfg = config.within.mysql;
in with lib; {
  options.within.mysql = { enable = mkEnableOption "MySQL"; };

  config = mkIf cfg.enable {
    services.mysql = {
      enable = true;

      package = pkgs.mariadb;

      settings.mysqld.skip_networking = true;
    };
  };
}
