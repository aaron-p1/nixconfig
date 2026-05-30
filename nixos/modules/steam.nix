{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.steam;
in
{
  _class = "nixos";

  options.within.steam = {
    enable = mkEnableOption "Steam";
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
    };
  };
}
