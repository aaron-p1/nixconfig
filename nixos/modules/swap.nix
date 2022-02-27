{ config, lib, pkgs, ... }:
let cfg = config.within.swap;
in with lib; {
  options.within.swap = {
    zram = mkEnableOption "zram swap";
    file = mkOption {
      type = types.int;
      default = 0;
      description = "Size of swap file in GB";
    };
  };

  config = mkMerge [
    (mkIf cfg.zram { zramSwap = { enable = true; }; })

    (mkIf (cfg.file > 0) {
      swapDevices = [{
        device = "/swapfile";
        size = 1024 * cfg.file;
        priority = 1;
      }];
    })
  ];
}
