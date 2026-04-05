{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.graphics.cosmic;
in
{
  options.within.graphics.cosmic = {
    enable = mkEnableOption "Cosmic Desktop";
    greeter = mkEnableOption "Cosmic Greeter";
  };

  config = mkIf cfg.enable {
    services = {
      displayManager.cosmic-greeter.enable = cfg.greeter;
      desktopManager.cosmic.enable = true;
      # disable because of bugs:
      # - sometimes 100% cpu usage
      # - sometimes not being able to boot
      system76-scheduler.enable = false;
      # This enables gcr-ssh-agent but I use gpg-agent
      # and I don't need keyring on encrypted system
      gnome.gnome-keyring.enable = false;
    };

    environment = {
      systemPackages = with pkgs; [
        cosmic-ext-applet-minimon
        cosmic-ext-applet-privacy-indicator
      ];
      cosmic.excludePackages = with pkgs; [
        cosmic-edit
        cosmic-player
      ];
    };
  };
}
