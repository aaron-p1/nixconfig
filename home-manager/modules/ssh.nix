{ config, lib, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf hasPrefix recursiveUpdate;

  cfg = config.within.ssh;

  additionalHostsContent = if config.within.enableEncryptedFileOptions then
    builtins.readFile ../../secrets/inline-secrets/additional-ssh-hosts.json
  else
    "{}";
  additionalHosts = builtins.fromJSON additionalHostsContent;

in {
  options.within.ssh = {
    enable = mkEnableOption "SSH";

    keyFiles = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        List of SSH key files to add to ssh-agent.
      '';
    };
  };

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
      controlPersist = "8h";
      matchBlocks = recursiveUpdate {
        "*".identityFile = mkIf (cfg.keyFiles != [ ]) cfg.keyFiles;
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
