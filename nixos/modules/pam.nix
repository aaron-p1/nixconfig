{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.within.pam;
in {
  options.within.pam = {
    u2f = {
      enable = mkEnableOption "pamu2f mappings";

      autolock = {
        enable = mkEnableOption "Auto lock when key inserted or removed";

        user = mkOption {
          type = types.str;
          description = "User to run the auto lock command as";
        };
      };
    };
  };

  config = mkIf cfg.u2f.enable {
    security.pam.u2f = {
      enable = true;
      cue = true;
      authFile = "/etc/u2f-mappings";
    };

    environment.etc."u2f-mappings" = {
      enable = true;
      text = "";
    };

    services.udev.extraRules = mkIf cfg.u2f.autolock.enable (let
      unlockScript = pkgs.writeShellScript "try-unlock" ''
        case "$1" in
          lock)
            ${pkgs.systemd}/bin/loginctl lock-sessions
            ;;
          unlock)
            ${pkgs.pamtester}/bin/pamtester \
              login "${cfg.u2f.autolock.user}" authenticate \
              < /dev/null \
              && ${pkgs.systemd}/bin/loginctl unlock-sessions
            ;;
        esac
      '';
    in ''
      # Auto lock when yubikey inserted or removed
      ACTION=="remove", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="1050/406*" RUN+="${unlockScript} lock"
      ACTION=="add", ENV{DEVTYPE}=="usb_device", ENV{ID_BUS}=="usb", ENV{PRODUCT}=="1050/406*", RUN+="${unlockScript} unlock"
    '');
  };
}
