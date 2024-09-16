{ config, lib, pkgs, ... }:
let
  inherit (builtins) readFile;
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.nsxiv;
in {
  options.within.nsxiv = { enable = mkEnableOption "nsxiv"; };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.nsxiv.override {
        conf = readFile ./config.def.h;
      })
    ];
  };
}
