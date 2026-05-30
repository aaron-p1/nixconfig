{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkForce
    ;

  cfg = config.within.tailscale;
in
{
  _class = "nixos";

  options.within.tailscale = {
    enable = mkEnableOption "Tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    systemd.services = {
      tailscaled = {
        wantedBy = mkForce [ "network-online.target" ];
        after = mkForce [ "network-online.target" ];
        wants = mkForce [ "network-online.target" ];
      };
    };
  };
}
