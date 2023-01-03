{ config, lib, pkgs, ... }:
let cfg = config.within.graphics.plasma;
in with lib; {
  options.within.graphics.plasma = {
    enable = mkEnableOption "Plasma Desktop";
    kdeConnect = mkEnableOption "Kde Connect";
    inputMethod = { japanese = mkEnableOption "Japanese Input Method"; };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;

      desktopManager.plasma5 = { enable = true; };
    };

    environment.systemPackages = with pkgs; [ latte-dock ];

    programs.kdeconnect.enable = cfg.kdeConnect;

    i18n.inputMethod = mkIf cfg.inputMethod.japanese {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        libsForQt5.fcitx5-qt
      ];
    };
  };
}
