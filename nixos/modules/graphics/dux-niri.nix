{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    types
    optionalString
    ;

  cfg = config.within.graphics.dux-niri;
in
{
  _class = "nixos";

  disabledModules = [
    "services/display-managers/dms-greeter.nix"
    "programs/wayland/dms-shell.nix"
  ];

  imports = [
    "${inputs.unstable}/nixos/modules/services/display-managers/dux-greeter.nix"
    "${inputs.unstable}/nixos/modules/programs/wayland/dux-shell.nix"
  ];

  options.within.graphics.dux-niri = {
    enable = mkEnableOption "Dux shell + Niri";
    greeter = {
      afterGpu = mkEnableOption "Start the greeter after the GPU is available";
      output = {
        name = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "The main output to configure for the greeter.";
        };
        mode = mkOption {
          type = types.str;
          description = "The mode to set for the main output.";
          example = "1920x1080@144.001";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services = {
      displayManager.dux-greeter = {
        enable = true;
        package = pkgs.unstable.dux-greeter;
        configHome = "/home/aaron";
        compositor = {
          name = "niri";
          customConfig = # kdl
          ''
            input {
              disable-power-key-handling

              keyboard {
                xkb {
                  layout "de"
                  variant "nodeadkeys"
                  options "caps:escape_shifted_capslock"
                }

                numlock
                repeat-delay 333
                repeat-rate 25
              }

              touchpad {
                tap
                natural-scroll
              }

              mouse {
                accel-profile "flat"
              }
            }

            binds {
              XF86PowerOff { spawn "dms" "ipc" "call" "powermenu" "toggle"; }
            }

            cursor {
              xcursor-theme "breeze_cursors"
              xcursor-size 24
            }

            hotkey-overlay {
              skip-at-startup
            }
          ''
          +
            optionalString (cfg.greeter.output.name != null) # kdl
              ''
                output "${cfg.greeter.output.name}" {
                  mode "${cfg.greeter.output.mode}"
                  scale 1
                  position x=0 y=0
                }
              '';
        };
      };
      logind.settings.Login.HandlePowerKey = "ignore";
      upower.enable = true;

      udev.extraRules = mkIf cfg.greeter.afterGpu ''
        ACTION=="add", SUBSYSTEM=="drm", KERNEL=="card1", TAG+="systemd"
      '';
    };

    systemd.user.services.dms.environment.QT_QPA_PLATFORMTHEME = "qtengine";
    qt.enable = true;

    programs = {
      dux-shell = {
        enable = true;
        package = pkgs.unstable.dux-shell;
        quickshell.package = pkgs.unstable.quickshell;

        systemd = {
          enable = true;
          restartIfChanged = false;
        };
      };

      niri.enable = true;
    };

    security.pam.services.dux-lock = { };

    environment.systemPackages =
      let
        breezeCursor = pkgs.runCommand "${pkgs.kdePackages.breeze.pname}-icons" { } ''
          mkdir -p $out/share
          ln -s ${pkgs.kdePackages.breeze}/share/icons $out/share/icons
        '';
      in
      [
        pkgs.qtengine
        pkgs.qt6Packages.qtstyleplugin-kvantum
        breezeCursor
      ];

    systemd.services.greetd = {
      serviceConfig.Type = lib.mkForce "simple";
      # make sure the gpu is available
      wants = mkIf cfg.greeter.afterGpu [ "dev-dri-card1.device" ];
      after = mkIf cfg.greeter.afterGpu [ "dev-dri-card1.device" ];
    };
  };
}
