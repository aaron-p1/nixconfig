{ pkgs, config, ... }:
{
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
}
