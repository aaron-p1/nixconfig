{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.xdg;
in
{
  _class = "homeManager";

  options.within.xdg = {
    enable = mkEnableOption "xdg config";
  };

  config = mkIf cfg.enable {
    xdg = {
      userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = true;
        # Defaults
      };

      mimeApps = {
        enable = true;
        defaultApplications =
          let
            nsxiv = "nsxiv.desktop";
            firefox = "firefox.desktop";
            nvim = "nvim.desktop";
            zathura = "org.pwmt.zathura.desktop";
          in
          {
            # Images
            "image/png" = nsxiv;
            "image/jpeg" = nsxiv;
            "image/gif" = nsxiv;
            "image/bmp" = nsxiv;
            "image/tiff" = nsxiv;
            # Documents
            "application/pdf" = zathura;
            "text/csv" = nvim;
            "text/html" = firefox;
            "text/plain" = nvim;
          };
      };
      configFile."mimeapps.list".force = true;
    };
  };
}
