{ config, lib, ... }:
let cfg = config.within.alacritty;
in with lib; {
  options.within.alacritty = { enable = mkEnableOption "Alacritty"; };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        window.dimensions = {
          lines = 28;
          columns = 100;
        };
        font.size = 9;
        key_bindings = [{
          key = "F11";
          action = "ToggleFullscreen";
        }];
      };
    };
  };
}
