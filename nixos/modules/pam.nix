{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    ;

  cfg = config.within.pam;
in
{
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
      settings = {
        cue = true;
        authfile = "/etc/u2f-mappings";
        # pamu2fcfg -o "pam://private" -i "pam://auth" -u [user]
        origin = "pam://private";
        appid = "pam://auth";
      };
    };

    environment.etc."u2f-mappings" = {
      enable = true;
      text = "";
    };

    services.udev.extraRules = mkIf cfg.u2f.autolock.enable (
      let
        loginctl = "${pkgs.systemd}/bin/loginctl";
        pamtester = "${pkgs.pamtester}/bin/pamtester";

        inherit (cfg.u2f.autolock) user;

        unlockScript = pkgs.writeShellScript "try-unlock" ''
          if ! ${loginctl} list-sessions | grep -q "${user}"; then
            exit 0
          fi

          case "$1" in
            lock)
              ${loginctl} lock-sessions
              ;;
            unlock)
              ${pamtester} login "${user}" authenticate < /dev/null \
                && ${loginctl} unlock-sessions
              ;;
          esac
        '';
      in
      ''
        # Auto lock when yubikey inserted or removed
        ACTION=="remove", ENV{DEVTYPE}=="usb_device", ENV{PRODUCT}=="1050/406*" RUN+="${unlockScript} lock"
        ACTION=="add", ENV{DEVTYPE}=="usb_device", ENV{ID_BUS}=="usb", ENV{PRODUCT}=="1050/406*", RUN+="${unlockScript} unlock"
      ''
    );
  };
}
