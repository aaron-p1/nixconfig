{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.shellScripts;

  copilot-cli = pkgs.writeShellApplication {
    name = "copilot-cli";

    runtimeInputs = [ pkgs.gh ];

    text = ''
      set -eu

      type=$1
      shift

      text="$*"

      gh copilot suggest -t "$type" "$text"
    '';
  };
in {
  options.within.shellScripts = {
    enable = mkEnableOption "Enable common shell scripts";
  };

  config = mkIf cfg.enable { home.packages = [ copilot-cli ]; };
}
