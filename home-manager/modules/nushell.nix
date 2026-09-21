{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.nushell;
in
{
  options.within.nushell = {
    enable = mkEnableOption "nushell config";
  };

  config = mkIf cfg.enable {
    programs = {
      nushell = {
        enable = true;
        package = pkgs.unstable.nushell;

        settings = {
          show_banner = false;

          history = {
            file_format = "sqlite";
            sync_on_enter = true;
            isolation = true;
            max_size = 10000000;
          };

          completions = {
            algorithm = "prefix";
          };

          highlight_resolved_externals = true;
          color_config = {
            shape_external = "red_bold";
            shape_external_resolved = "green";
            shape_internalcall = "cyan";
          };

          use_kitty_protocol = true;
        };

        shellAliases = {
          free = "free -h";
          df = "df -h";
          cdtmp = "cd (mktemp -d)";

          o = "xdg-open";
          eg = "nvim +Git +'bdelete 1'";
        };

        environmentVariables = {
          SHELL = lib.hm.nushell.mkNushellInline "$nu.current-exe";
        };
      };

      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };

    home.shell.enableNushellIntegration = true;
    programs.direnv.enableNushellIntegration = true;
  };
}
