{ config, lib, pkgs, ... }:
let
  inherit (lib)
    mkEnableOption mkOption types mkIf mkDefault versionAtLeast optionalAttrs
    optional optionals;

  cfg = config.within.containers;
in {
  options.within.containers = {
    enable = mkEnableOption "container support";
    enableNvidia = mkEnableOption "NVIDIA container support";

    networkOptions = mkOption {
      type = types.listOf types.str;
      default = [ "allow_host_loopback=true" ];
      description = "containersConf.settings.engine.network_cmd_options";
    };

    podman = mkEnableOption "podman";
  };

  config = mkIf cfg.enable {
    # warning: Enabling both boot.enableContainers & virtualisation.containers
    #          on system.stateVersion < 22.05 is unsupported.
    boot.enableContainers =
      mkDefault (versionAtLeast config.system.stateVersion "22.05");

    virtualisation = {
      containers = {
        enable = true;
        containersConf = {
          settings = {
            engine = {
              network_cmd_options = cfg.networkOptions;
              compose_providers =
                [ "${pkgs.docker-compose}/bin/docker-compose" ];
            };
          };
        };
      };

      podman = optionalAttrs cfg.podman {
        enable = true;
        dockerCompat = true;
      };

      oci-containers.backend = "podman";
    };

    hardware.nvidia-container-toolkit.enable = cfg.enableNvidia;
    environment.etc."cdi/nvidia-container-toolkit.json" =
      mkIf cfg.enableNvidia {
        source = "/var/run/cdi/nvidia-container-toolkit.json";
      };

    # fix service not finding newuidmap and newgidmap
    # https://github.com/NixOS/nixpkgs/issues/138423#issuecomment-947888673
    systemd.user.services.podman.path = optional cfg.podman "/run/wrappers";

    environment.systemPackages = optionals cfg.podman [
      pkgs.podman-compose
      (pkgs.writeShellScriptBin "podman-remote" ''
        exec ${pkgs.podman}/bin/podman --remote "$@"
      '')
    ] ++ optional cfg.enableNvidia
      config.hardware.nvidia-container-toolkit.package;
  };
}
