{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.gh;
in {
  options.within.gh.enable = mkEnableOption "Gh";

  config = mkIf cfg.enable {
    programs.gh = {
      enable = true;
      extensions = [ pkgs.gh-copilot ];
    };

    home.packages = [
      (pkgs.writeShellScriptBin "copilot-cli" ''
        type=$1
        shift

        text="$*"

        gh copilot suggest -t "$type" "$text"
      '')
    ];
  };
}
