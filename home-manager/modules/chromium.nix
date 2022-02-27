{ config, lib, ... }:
let cfg = config.within.chromium;
in with lib; {
  options.within.chromium = { enable = mkEnableOption "Chromium"; };

  config = mkIf cfg.enable { programs.chromium = { enable = true; }; };
}
