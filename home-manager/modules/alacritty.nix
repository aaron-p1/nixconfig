{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mapAttrsToList
    concatLists
    ;

  cfg = config.within.alacritty;
in
{
  options.within.alacritty = {
    enable = mkEnableOption "Alacritty";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nerd-fonts.fira-code ];

    programs.alacritty = {
      enable = true;

      settings = {
        window.dimensions = {
          lines = 28;
          columns = 100;
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
        keyboard.bindings =
          let
            mod = "Control|Shift";
            keys = {
              A = 65;
              B = 66;
              # C = 67; # copy
              D = 68;
              E = 69;
              # F = 70; # search
              G = 71;
              # H = 72; # copy sha256
              I = 73;
              J = 74;
              K = 75;
              L = 76;
              M = 77;
              # N = 78; # new instance
              O = 79;
              # P = 80; # copy path
              Q = 81;
              R = 82;
              S = 83;
              T = 84;
              # U = 85; # open url
              # V = 86; # paste
              W = 87;
              X = 88;
              Y = 89;
              Z = 90;
            };

            ctrlShiftMappings = mapAttrsToList (key: code: {
              inherit key;
              mods = mod;
              chars = "\\u001B[${toString code};6u";
            }) keys;
          in
          concatLists [
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
            ctrlShiftMappings
          ];
      };
    };
  };
}
