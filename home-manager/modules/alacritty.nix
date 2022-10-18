{ config, lib, pkgs, ... }:
let cfg = config.within.alacritty;
in with lib; {
  options.within.alacritty = { enable = mkEnableOption "Alacritty"; };

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
  };
}
