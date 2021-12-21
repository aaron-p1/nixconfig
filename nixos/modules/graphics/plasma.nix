{ config, lib, pkgs, ... }:
let
  cfg = config.within.graphics.plasma;
in
with lib; {
  options.within.graphics.plasma = {
    enable = mkEnableOption "Plasma Desktop";
    kdeConnect = mkEnableOption "Kde Connect";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      desktopManager.plasma5 = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      latte-dock
    ];

    programs.kdeconnect.enable = cfg.kdeConnect;
  };
}
