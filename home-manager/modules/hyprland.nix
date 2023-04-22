{ config, osConfig, lib, pkgs, ... }:
let
  cfg = config.within.hyprland;

  osCfg = osConfig.programs.hyprland;
in with lib; {
  options.within.hyprland = { };

  config = mkIf osCfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      inherit (osCfg) package xwayland nvidiaPatches;

      recommendedEnvironment = true;

      extraConfig = with pkgs; let
        launcher = "${rofi-wayland}/bin/rofi -show drun";
      in ''

        exec-once = ${swaynotificationcenter}/bin/swaync &
        exec-once = ${libsForQt5.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1 &

        env = QT_QPA_PLATFORM,wayland

        input {
          kb_layout = de
          kb_variant = nodeadkeys
          kb_model = pc105
          kb_options = caps:escape,compose:sclk,nbsp:level3
          kb_rules = evdev

          numlock_by_default = true

          repeat_rate = 25
          repeat_delay = 333

          accel_profile = flat

          follow_mouse = true
        }

        general {
          gaps_in = 0
          gaps_out = 0

          layout = dwindle
        }

        animations {
          bezier = slow-end, 0.13, 0.15, 0.25, 1.00

          animation = windows, 1, 2, default
          animation = border, 1, 2, default
          animation = borderangle, 1, 2, default
          animation = fade, 1, 2, default
          animation = workspaces, 1, 2, default
        }

        dwindle {
          force_split = 2
        }

        $mod = SUPER

        bind = SUPER, Return, exec, alacritty
        bind = SUPER, f, exec, firefox

        # manage hyprland
        bind = $mod, q, killactive
        bind = $mod, x, exit

        # manage windows
        bind = $mod, h, movefocus, l
        bind = $mod, j, movefocus, d
        bind = $mod, k, movefocus, u
        bind = $mod, l, movefocus, r

        bind = $mod CTRL, a, workspace, 1
        bind = $mod CTRL, b, workspace, 2
        bind = $mod CTRL, c, workspace, 3
        bind = $mod CTRL, d, workspace, 4
        bind = $mod CTRL, e, workspace, 5
        bind = $mod CTRL, f, workspace, 6
        bind = $mod CTRL, g, workspace, 7
        bind = $mod CTRL, h, workspace, 8
        bind = $mod CTRL, i, workspace, 9
        bind = $mod CTRL, j, workspace, 10

        bind = $mod CTRL SHIFT, a, movetoworkspace, 1
        bind = $mod CTRL SHIFT, b, movetoworkspace, 2
        bind = $mod CTRL SHIFT, c, movetoworkspace, 3
        bind = $mod CTRL SHIFT, d, movetoworkspace, 4
        bind = $mod CTRL SHIFT, e, movetoworkspace, 5
        bind = $mod CTRL SHIFT, f, movetoworkspace, 6

        bind = $mod, mouse_down, workspace, e+1
        bind = $mod, mouse_up, workspace, e-1

        bindm = $mod, mouse:272, movewindow
        bindm = $mod, mouse:273, resizewindow

        # launch
        bind = $mod, s, exec, ${launcher}
      '';
    };

    within.eww.enable = true;
  };
}
