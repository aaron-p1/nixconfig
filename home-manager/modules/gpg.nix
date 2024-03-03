{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.gpg;
in {
  options.within.gpg = { enable = mkEnableOption "Gpg"; };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      package = pkgs.gnupg.override {
        guiSupport = true;
        pinentry = pkgs.pinentry.qt;
      };
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "qt";
    };
  };
}
