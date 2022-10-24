{ config, lib, pkgs, ... }:
let
  cfg = config.within.alacritty;

  inherit (builtins) listToAttrs;
in with lib; {
  options.within.alacritty = {
    enable = mkEnableOption "Alacritty";
    shortcuts = {
      nixconfig = mkEnableOption "Nixconfig";
      oro = mkEnableOption "Oro";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ (nerdfonts.override { fonts = [ "Hack" ]; }) ];

    programs.alacritty = {
      enable = true;

      settings = {
        window.dimensions = {
          lines = 28;
          columns = 100;
        };
        font = {
          size = 9;
          normal = { family = "Hack Nerd Font"; };
        };
        mouse.hide_when_typing = true;
        hints = {
          alphabet = "abcdefghjklmnopqrstuvwxyz";
          enabled = [
            {
              regex = ''
                (ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>"\\s{-}\\^⟨⟩`]+'';
              hyperlinks = true;
              command = "xdg-open";
              post_processing = true;
              mouse = {
                enabled = true;
                mods = "None";
              };
              binding = {
                key = "U";
                mods = "Control|Shift";
              };
            }
            {
              regex = "(/|[.]/|[.][.]/|\\\\S+/)\\\\S+";
              action = "Copy";
              post_processing = true;
              binding = {
                key = "P";
                mods = "Control|Shift";
              };
            }
            {
              regex = "sha256-\\\\S{44}";
              action = "Copy";
              post_processing = false;
              binding = {
                key = "H";
                mods = "Control|Shift";
              };
            }
          ];
        };
        key_bindings = [{
          key = "F11";
          action = "ToggleFullscreen";
        }];
      };
    };

    xdg.desktopEntries = let
      alacrittyPath = "${pkgs.alacritty}";

      aBin = alacrittyPath + "/bin/alacritty";
      aFullscreen = "-o window.startup_mode=Fullscreen";
      icon = alacrittyPath + "/share/icons/hicolor/scalable/apps/Alacritty.svg";

    in listToAttrs (map ({ name, shortName, command, settings ? { } }: {
      name = shortName;
      value = {
        inherit name icon settings;
        exec = "${aBin} ${aFullscreen} -e ${command}";
      };
    }) (optional cfg.shortcuts.nixconfig {
      name = "Nixconfig";
      shortName = "nixconfig";
      command = "gotmux nixconfig";
    } ++ optional cfg.shortcuts.oro {
      name = "Orgmode optimize";
      shortName = "oro";
      command = let inherit (config.xdg.userDirs) documents;
      in "nvim ${documents}/private/orgmode/optimize.org";
      settings.Keywords = "oro";
    }));
  };
}
