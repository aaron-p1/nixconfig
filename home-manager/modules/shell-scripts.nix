{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.shellScripts;

  run-editor = pkgs.writeShellScriptBin "e" ''
    set -eu

    if [ -z "$EDITOR" ]; then
      echo "EDITOR is not set" >&2
      exit 1
    fi

    eval exec $EDITOR "$@"
  '';

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

  config = mkIf cfg.enable { home.packages = [ run-editor copilot-cli ]; };
}
