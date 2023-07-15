{ config, osConfig, lib, ... }:
let
  cfg = config.within.plasma;
  systemPlasma = osConfig.services.xserver.desktopManager.plasma5;
in with lib; {
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
