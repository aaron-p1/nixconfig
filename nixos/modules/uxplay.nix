{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.uxplay;
in
{
  options.within.uxplay = {
    enable = mkEnableOption "Enable uxplay";
  };

  config = mkIf cfg.enable {
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 38500;
          to = 38502;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 38500;
          to = 38502;
        }
      ];
    };

    environment.systemPackages =
      let
        uxplay = pkgs.writeShellScriptBin "uxplay" ''
          ${pkgs.uxplay}/bin/uxplay -p 38500 "$@"
        '';
      in
      [ uxplay ];
  };
}
