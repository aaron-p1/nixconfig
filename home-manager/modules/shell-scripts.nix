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
in {
  options.within.shellScripts = {
    enable = mkEnableOption "Enable common shell scripts";
  };

  config = mkIf cfg.enable { home.packages = [ run-editor ]; };
}
