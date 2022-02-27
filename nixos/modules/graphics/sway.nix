{ config, lib, pkgs, ... }:
let cfg = config.within.graphics.sway;
in with lib; {
  options.within.graphics.sway = { enable = mkEnableOption "Sway"; };

  config = mkIf cfg.enable {
    # vm sway fix
    environment.variables.WLR_RENDERER_ALLOW_SOFTWARE = "1";

    # packages
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock
        swayidle
        xwayland
        waybar
        wl-clipboard
        mako
        alacritty
        dmenu
      ];
    };

    # start sway program
    environment.systemPackages = with pkgs;
      [
        (pkgs.writeTextFile {
          name = "startsway";
          destination = "/bin/startsway";
          executable = true;
          text = ''
            #! ${pkgs.bash}/bin/bash

            systemctl --user import-environment
            exec systemctl --user start sway.service
          '';
        })
      ];

    systemd.user.targets.sway-session = {
      description = "Sway compositor session";
      documentation = [ "man:systemd.special(7)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };

    systemd.user.services.sway = {
      description = "Sway - Wayland window manager";
      documentation = [ "man:sway(5)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
      # We explicitly unset PATH here, as we want it to be set by
      # systemctl --user import-environment in startsway
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
        '';
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    programs.waybar.enable = true;

    systemd.user.services.swayidle = {
      description = "Idle Manager for Wayland";
      documentation = [ "man:swayidle(1)" ];
      wantedBy = [ "sway-session.target" ];
      partOf = [ "graphical-session.target" ];
      path = [ pkgs.bash ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.swayidle}/bin/swayidle -w -d \
                 timeout 300 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
                 resume '${pkgs.sway}/bin/swaymsg "output * dpms on"'
               '';
      };
    };

    systemd.user.services.kanshi = {
      description = "Kanshi output autoconfig ";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        # kanshi doesn't have an option to specifiy config file yet, so it looks
        # at .config/kanshi/config
        ExecStart = ''
          ${pkgs.kanshi}/bin/kanshi
        '';
        RestartSec = 5;
        Restart = "always";
      };
    };
  };
}
