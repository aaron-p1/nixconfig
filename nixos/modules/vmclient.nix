{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.vmclient;
in
{
  _class = "nixos";

  options.within.vmclient = {
    enable = mkEnableOption "VmClient config";
  };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
  };
}
