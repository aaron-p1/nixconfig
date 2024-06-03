{ config, lib, pkgs, ... }:
let
  inherit (builtins) removeAttrs replaceStrings;
  inherit (lib) mkEnableOption mkIf optional listToAttrs;

  cfg = config.within.xdg;
in {
  options.within.xdg = {
    enable = mkEnableOption "xdg config";

    desktopEntries = {
      enable = mkEnableOption "Desktop entries";

      terminal.nixconfig = mkEnableOption "Nixconfig";
    };
  };

  config = mkIf cfg.enable {
    xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
        # Defaults
      };

      mimeApps = {
        enable = true;
        defaultApplications = let
          feh = "feh.desktop";
          firefox = "firefox.desktop";
          nvim = "nvim.desktop";
          zathura = "org.pwmt.zathura.desktop";
        in {
          # Images
          "image/png" = feh;
          "image/jpeg" = feh;
          "image/gif" = feh;
          "image/bmp" = feh;
          "image/tiff" = feh;
          # Documents
          "application/pdf" = zathura;
          "text/csv" = nvim;
          "text/html" = firefox;
          "text/plain" = nvim;
        };
      };
      configFile."mimeapps.list".force = true;

      desktopEntries = let
        terminalCfg = cfg.desktopEntries.terminal;

        terminalCmd = "${pkgs.alacritty}/bin/alacritty"
          + " -o \"window.startup_mode='Fullscreen'\"" + " -e {}";

        terminalIcon = "${pkgs.alacritty}"
          + "/share/icons/hicolor/scalable/apps/Alacritty.svg";

        terminalEntries = map (args@{ command, ... }:
          removeAttrs args [ "command" ] // {
            exec = replaceStrings [ "{}" ] [ command ] terminalCmd;
            icon = terminalIcon;
          }) (optional terminalCfg.nixconfig {
            name = "Nixconfig";
            shortName = "nixconfig";
            command = ''${pkgs.zsh}/bin/zsh -c "gotmux nixconfig"'';
            settings.Keywords = "nc";
          });
      in mkIf cfg.desktopEntries.enable (listToAttrs (map (args: {
        name = args.shortName;
        value = builtins.removeAttrs args [ "shortName" ];
      }) terminalEntries));
    };
  };
}
