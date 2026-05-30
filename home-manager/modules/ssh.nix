{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    mkIf
    hasPrefix
    recursiveUpdate
    ;

  cfg = config.within.ssh;

  additionalHostsContent =
    if config.within.enableEncryptedFileOptions then
      builtins.readFile ../../secrets/inline-secrets/additional-ssh-hosts.json
    else
      "{}";
  additionalHosts = builtins.fromJSON additionalHostsContent;

in
{
  _class = "homeManager";

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
    assertions = [
      {
        assertion = hasPrefix "{" additionalHostsContent;
        message = ''
          Host file does not start with {. If it's encrypted you could
          set within.enableEncryptedFileOptions to false in home-manager config.
        '';
      }
    ];

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = recursiveUpdate {
        "*" = {
          IdentityFile = mkIf (cfg.keyFiles != [ ]) cfg.keyFiles;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/sockets/%r@%n:%p";
          ControlPersist = "8h";
        };
        pc = {
          Hostname = "aaron-pc";
          User = "aaron";
          Port = 25566;
        };
        laptop = {
          Hostname = "aaron-laptop";
          User = "aaron";
          Port = 25566;
        };
        thinkpad = {
          Hostname = "aaron-thinkpad";
          User = "aaron";
          Port = 25566;
        };
      } additionalHosts;
    };
  };
}
