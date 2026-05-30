{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    concatLists
    ;

  cfg = config.within.alacritty;
in
{
  _class = "homeManager";

  options.within.alacritty = {
    enable = mkEnableOption "Alacritty";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nerd-fonts.fira-code ];

    programs.alacritty = {
      enable = true;

      settings = {
        window = {
          opacity = if osConfig.within.graphics.dms-niri.enable then 0.95 else 1.0;
          dimensions = {
            lines = 28;
            columns = 100;
          };
        };
        colors = {
          transparent_background_colors = osConfig.within.graphics.dms-niri.enable;
        };
        font = {
          size = 9;
          normal = {
            family = "FiraCode Nerd Font";
          };
        };
        mouse.hide_when_typing = true;
        hints = {
          alphabet = "abcdefghjklmnopqrstuvwxyz";
          enabled = [
            {
              regex = ''(ipfs:|ipns:|magnet:|mailto:|gemini:|gopher:|https:|http:|news:|file:|git:|ssh:|ftp:)[^\u0000-\u001F\u007F-\u009F<>"\\s{-}\\^⟨⟩`]+'';
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
        keyboard.bindings = concatLists [
          [
            {
              key = "F11";
              action = "ToggleFullscreen";
            }
            {
              mods = "Control|Shift";
              key = "n";
              action = "SpawnNewInstance";
            }
          ]
        ];
      };
    };
  };
}
