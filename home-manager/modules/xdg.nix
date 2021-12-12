{ config, lib, ... }:
let cfg = config.within.xdg;
in with lib; {
  options.within.xdg = { enable = mkEnableOption "xdg config"; };

  config = mkIf cfg.enable {
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      # Defaults
    };
  };
}
