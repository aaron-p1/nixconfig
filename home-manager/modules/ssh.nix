{ config, lib, ... }:
let
  cfg = config.within.ssh;

  additionalHostsContent =
    builtins.readFile ../../secrets/inline-secrets/additional-ssh-hosts.json;
  additionalHosts = builtins.fromJSON additionalHostsContent;

in with lib; {
  options.within.ssh = { enable = mkEnableOption "SSH"; };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = hasPrefix "{" additionalHostsContent;
      message = "Host file does not start with {"; # }}
    }];

    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%n:%p";
      matchBlocks = recursiveUpdate {
        laptop = {
          hostname = "aaron-laptop";
          user = "aaron";
          port = 25566;
        };
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
      } additionalHosts;
    };
  };
}
