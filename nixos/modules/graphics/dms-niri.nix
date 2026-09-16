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
    mkIf
    types
    optionalString
    ;

  cfg = config.within.graphics.dms-niri;
in
{
  _class = "nixos";

  options.within.graphics.dms-niri = {
    enable = mkEnableOption "DMS + Niri";
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
    services =
      let
        inherit (lib)
          getExe
          makeBinPath
          escapeShellArgs
          mkForce
          ;

        cacheDir = "/var/lib/dms-greeter";

        greeterScript = pkgs.writeShellScriptBin "dms-greeter-start" ''
          export PATH=$PATH:${
            makeBinPath [
              pkgs.unstable.quickshell
              pkgs.unstable.niri
              pkgs.glib # provides gdbus, used by the fprintd hardware probe and portal reads
            ]
          }
          ${escapeShellArgs (
            [
              "${pkgs.unstable.dms-greeter}/bin/dms-greeter"
              "--cache-dir"
              cacheDir
              "--command"
              "niri"
            ]
            ++ lib.optionals (customConfig != "") [
              "-C"
              "${pkgs.writeText "dmsgreeter-compositor-config" customConfig}"
            ]
          )}
        '';

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
      in
      {
        greetd.settings.default_session.command = mkForce (getExe greeterScript);
        displayManager.dms-greeter = {
          enable = true;
          package = pkgs.unstable.dms-greeter;
          configHome = "/home/aaron";
          compositor = {
            name = "niri";
            inherit customConfig;
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
      dms-shell = {
        enable = true;
        package = pkgs.unstable.dms-shell;
        quickshell.package = pkgs.unstable.quickshell;

        systemd = {
          enable = true;
          restartIfChanged = false;
        };

        enableVPN = true;
        enableDynamicTheming = true;
        enableAudioWavelength = false;
        enableCalendarEvents = false;
      };

      niri.enable = true;
    };

    security.pam.services.dms-lock = { };

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
