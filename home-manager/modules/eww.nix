{ config, lib, pkgs, ... }:
let cfg = config.within.eww;
in with lib; {
  options.within.eww = { enable = mkEnableOption "EWW"; };

  config = mkIf cfg.enable {
    programs.eww = {
      enable = true;
      package = pkgs.eww-wayland;
      configDir = pkgs.dotfiles.eww;
    };

    # if not recursive, eww commands will fail
    xdg.configFile."eww".recursive = true;
  };
}
