{ config, lib, ... }:
let
  cfg = config.within.ssh;

  additionalHostsContent = if config.within.enableEncryptedFileOptions then
    builtins.readFile ../../secrets/inline-secrets/additional-ssh-hosts.json
  else
    "{}";
  additionalHosts = builtins.fromJSON additionalHostsContent;

in with lib; {
  options.within.ssh = { enable = mkEnableOption "SSH"; };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = hasPrefix "{" additionalHostsContent;
      message = ''
        Host file does not start with {. If it's encrypted you could
        set within.enableEncryptedFileOptions to false in home-manager config.
      ''; # }}
    }];

    programs.ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/%r@%n:%p";
      matchBlocks = recursiveUpdate {
        pc = {
          hostname = "aaron-pc";
          user = "aaron";
          port = 25566;
        };
        laptop = {
          hostname = "aaron-laptop";
          user = "aaron";
          port = 25566;
        };
      } additionalHosts;
    };
  };
}
