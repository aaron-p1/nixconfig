{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.ghostty;
in
{
  options.within.ghostty = {
    enable = mkEnableOption "Ghostty";
  };

  config = mkIf cfg.enable {
    programs.ghostty =
      let
        keybinds = {
          "ctrl+shift+n" = "new_window";

          "ctrl+shift+f" = "start_search";
          # "escape" = "end_search";

          "copy" = "copy_to_clipboard:mixed";
          "ctrl+shift+c" = "copy_to_clipboard:mixed";
          "paste" = "paste_from_clipboard";
          "ctrl+shift+v" = "paste_from_clipboard";

          "shift+page_down" = "scroll_page_down";
          "shift+page_up" = "scroll_page_up";
          "shift+end" = "scroll_to_bottom";
          "shift+home" = "scroll_to_top";
          "ctrl+shift+page_down" = "jump_to_prompt:1";
          "ctrl+shift+page_up" = "jump_to_prompt:-1";

          "shift+arrow_down" = "adjust_selection:down";
          "shift+arrow_left" = "adjust_selection:left";
          "shift+arrow_right" = "adjust_selection:right";
          "shift+arrow_up" = "adjust_selection:up";

          "ctrl+shift+p" = "toggle_command_palette";

          "ctrl++" = "increase_font_size:1";
          "ctrl+-" = "decrease_font_size:1";
          "ctrl+0" = "reset_font_size";

          "F11" = "toggle_fullscreen";
        };
      in
      {
        enable = true;
        enableZshIntegration = true;
        clearDefaultKeybinds = true;
        settings = {
          window-height = 28;
          window-width = 100;
          window-padding-balance = false;
          window-padding-y = 0;
          window-padding-x = 0;
          resize-overlay = "never";

          background-opacity = 0.9;
          background-opacity-cells = true;
          background-blur = true;

          font-family = "FiraCode Nerd Font";
          font-size = 9;
          adjust-cell-width = "+0%";
          adjust-cell-height = "+4%";

          mouse-hide-while-typing = true;
          app-notifications = [ "no-clipboard-copy" ];
          notify-on-command-finish = "unfocused";

          theme = "alacritty";
          working-directory = "home";
          window-inherit-working-directory = false;
          link-previews = "osc8";

          custom-shader = "${./cursor-smear.glsl}";
          custom-shader-animation = true;

          keybind = lib.mapAttrsToList (key: action: "${key}=${action}") keybinds;
        };
        themes.alacritty = {
          background = "181818";
          foreground = "D8D8D8";
          cursor-color = "D8D8D8";
          selection-background = "cell-foreground";
          selection-foreground = "cell-background";

          palette = [
            "0=#181818"
            "1=#AC4242"
            "2=#90A959"
            "3=#F4BF75"
            "4=#6A9FB5"
            "5=#AA759F"
            "6=#75B5AA"
            "7=#D8D8D8"
            "8=#6B6B6B"
            "9=#C55555"
            "10=#AAC474"
            "11=#FECA88"
            "12=#82B8C8"
            "13=#C28CB8"
            "14=#93D3C3"
            "15=#F8F8F8"
          ];
        };
        systemd.enable = true;
      };
  };
}
