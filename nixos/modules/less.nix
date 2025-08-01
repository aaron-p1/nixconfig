{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.less;
in
{
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
