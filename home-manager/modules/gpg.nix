{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.gpg;
in
{
  options.within.gpg = {
    enable = mkEnableOption "Gpg";
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-qt;
    };
  };
}
