{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.chromium;
in {
  options.within.chromium = { enable = mkEnableOption "Chromium"; };

  config = mkIf cfg.enable { programs.chromium = { enable = true; }; };
}
