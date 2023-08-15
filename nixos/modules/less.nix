{ config, lib, ... }:
let
  cfg = config.within.less;
in with lib; {
  options.within.less = {
    enable = mkEnableOption "Less";
  };

  config = mkIf cfg.enable {
    programs.less = {
      enable = true;
      commands = {
        K = "toggle-option -redraw-on-quit\\n";
      };
    };
  };
}
