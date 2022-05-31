{ config, lib, ... }:
let cfg = config.within.direnv;
in with lib; {
  options.within.direnv = { enable = mkEnableOption "Direnv"; };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = { enable = true; };
      config = {
        load_dotenv = false;
        warn_timeout = "0";
      };
    };
  };
}
