{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.direnv;
in {
  options.within.direnv = { enable = mkEnableOption "Direnv"; };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv = { enable = true; };
      config = {
        load_dotenv = false;
        warn_timeout = "1h";
      };
    };
  };
}
