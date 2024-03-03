{ config, lib, ... }:
let
  inherit (lib) mkOption types mkMerge mkIf;

  cfg = config.within.swap;
in {
  options.within.swap = {
    zram = mkOption {
      type = types.int;
      default = 0;
      description = "zram swap size in percent";
    };
    file = mkOption {
      type = types.int;
      default = 0;
      description = "Size of swap file in GB";
    };
  };

  config = mkMerge [
    (mkIf (cfg.zram != 0) {
      zramSwap = {
        enable = true;
        memoryPercent = cfg.zram;
      };
    })

    (mkIf (cfg.file > 0) {
      swapDevices = [{
        device = "/swapfile";
        size = 1024 * cfg.file;
        priority = 1;
      }];
    })
  ];
}
