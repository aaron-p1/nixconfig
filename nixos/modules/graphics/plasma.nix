{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.graphics.plasma;
in {
  options.within.graphics.plasma = {
    enable = mkEnableOption "Plasma Desktop";
    kdeConnect = mkEnableOption "Kde Connect";
    inputMethod = { japanese = mkEnableOption "Japanese Input Method"; };
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      konsole
      kate
      khelpcenter
      okular
      elisa
    ];

    programs.kdeconnect.enable = cfg.kdeConnect;

    i18n.inputMethod = mkIf cfg.inputMethod.japanese {
      enable = true;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        kdePackages.fcitx5-qt
      ];
    };
  };
}
