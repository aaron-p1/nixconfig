{ config, lib, pkgs, ... }:
let cfg = config.within.containers;
in with lib; {
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
    # warning: Enabling both boot.enableContainers & virtualisation.containers
    #          on system.stateVersion < 22.05 is unsupported.
    boot.enableContainers = mkDefault (versionAtLeast config.system.stateVersion "22.05");

    virtualisation = {
      containers = {
        enable = true;
        containersConf = {
          settings = { engine.network_cmd_options = cfg.networkOptions; };
          cniPlugins = with pkgs; [ dnsname-cni ];
        };
      };

      podman = optionalAttrs cfg.podman {
        enable = true;
        enableNvidia = true;
        dockerCompat = true;
      };

      oci-containers.backend = "podman";
    };

    # fix service not finding newuidmap and newgidmap
    # https://github.com/NixOS/nixpkgs/issues/138423#issuecomment-947888673
    systemd.user.services.podman.path = optional cfg.podman "/run/wrappers";

    environment.systemPackages = optional cfg.podman pkgs.podman-compose;
  };
}
