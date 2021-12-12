{ config, lib, ... }:
let cfg = config.within.alacritty;
in with lib; {
  options.within.alacritty = { enable = mkEnableOption "Alacritty"; };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        window.dimensions = {
          lines = 24;
          columns = 80;
        };
        key_bindings = [{
          key = "F11";
          action = "ToggleFullscreen";
        }];
      };
    };
  };
}
