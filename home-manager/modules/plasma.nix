{ config, osConfig, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.plasma;
  systemPlasma = osConfig.services.xserver.desktopManager.plasma6;
in {
  options.within.plasma = {
    enableKWallet = mkEnableOption "KWallet" // {
      default = true;
      example = false;
    };
  };

  config = mkIf systemPlasma.enable {
    xdg.configFile.kwalletrc = mkIf (!cfg.enableKWallet) {
      text = ''
        [Wallet]
        Enabled=false
      '';
    };
  };
}
