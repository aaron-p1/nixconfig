{ config, lib, ... }:
let cfg = config.within.ssh;
in with lib; {
  options.within.ssh = { enable = mkEnableOption "SSH"; };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%n:%p";
      matchBlocks = {
        public-server = {
          hostname = "public-server";
          user = "aaron";
          port = 25566;
        };
        public-server-root = {
          hostname = "public-server";
          user = "root";
          port = 25566;
        };
      };
    };
  };
}
