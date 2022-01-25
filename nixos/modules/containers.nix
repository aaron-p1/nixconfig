{ config, lib, pkgs, ... }:
let
  cfg = config.within.containers;
in
with lib; {
  options.within.containers = {
    enable = mkEnableOption "container support";
    networkOptions = mkOption {
      type = with types; listOf str;
      default = [ "allow_host_loopback=true" ];
      description = "containersConf.settings.engine.network_cmd_options";
    };

    podman = mkEnableOption "podman";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      containers = {
        enable = true;
        containersConf = {
          settings = {
            engine.network_cmd_options = cfg.networkOptions;
          };
          cniPlugins = with pkgs; [
            dnsname-cni
          ];
        };
      };

      podman = optionalAttrs cfg.podman {
        enable = true;
        enableNvidia = true;
        dockerCompat = true;
      };

      oci-containers.backend = "podman";
    };

    environment.systemPackages = optional cfg.podman pkgs.podman-compose;
  };
}
