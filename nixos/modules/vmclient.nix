{ config, lib, ... }:
let cfg = config.within.vmclient;
in with lib; {
  options.within.vmclient = { enable = mkEnableOption "VmClient config"; };

  config = mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
  };
}
