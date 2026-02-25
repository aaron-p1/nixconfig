{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.man;
in
{
  options.within.man = {
    enable = mkEnableOption "Man pages";
  };

  config = mkIf cfg.enable {
    documentation = {
      dev.enable = true;
      man = {
        enable = true;
        generateCaches = true;
        man-db = {
          enable = true;
          manualPages =
            let
              manDBCfg = config.documentation.man.man-db;

              packages = builtins.concatLists [
                config.environment.systemPackages
                config.home-manager.users.aaron.home.packages
              ];
            in
            pkgs.buildEnv {
              name = "man-paths";
              paths = lib.subtractLists manDBCfg.skipPackages packages;
              pathsToLink = [ "/share/man" ];
              extraOutputsToInstall = [ "man" ] ++ lib.optionals config.documentation.dev.enable [ "devman" ];
              ignoreCollisions = true;
            };
        };
      };
    };
  };
}
