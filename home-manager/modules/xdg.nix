{ config, lib, pkgs, ... }:
let
  inherit (builtins) removeAttrs replaceStrings;

  cfg = config.within.xdg;
in with lib; {
  options.within.xdg = {
    enable = mkEnableOption "xdg config";

    desktopEntries = {
      enable = mkEnableOption "Desktop entries";

      terminal = {
        nixconfig = mkEnableOption "Nixconfig";
        oro = mkEnableOption "Orgmode optimize";
      };

      links = { nixpkgs = mkEnableOption "Nixpkgs"; };
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
          } ++ optional terminalCfg.oro {
            name = "Orgmode optimize";
            shortName = "oro";
            command = let inherit (config.xdg.userDirs) documents;
            in "nvim ${documents}/private/orgmode/optimize.org";
            settings.Keywords = "oro";
          });

        linkEntries = map (args@{ url, ... }:
          removeAttrs args [ "url" ] // {
            exec = "xdg-open ${url}";
          }) (optionals cfg.desktopEntries.links.nixpkgs [
            {
              name = "Nixpkgs";
              shortName = "nixpkgs";
              url = "https://github.com/NixOS/nixpkgs";
              icon = "nix-snowflake";
              settings.Keywords = "np";
            }
            {
              name = "Nixpkgs unstable";
              shortName = "nixpkgs-unstable";
              url = "https://github.com/NixOS/nixpkgs/tree/nixos-unstable";
              icon = "nix-snowflake";
              settings.Keywords = "nu";
            }
          ]);

        entries = terminalEntries ++ linkEntries;
      in mkIf cfg.desktopEntries.enable (listToAttrs (map (args: {
        name = args.shortName;
        value = builtins.removeAttrs args [ "shortName" ];
      }) entries));
    };
  };
}
