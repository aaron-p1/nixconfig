{ config, lib, pkgs, ... }:
let cfg = config.within.tailscale;
in with lib; {
  options.within.tailscale = {
    enable = mkEnableOption "Tailscale";

    download = {
      enable = mkEnableOption "Tailscale File Download Service";
      owner = mkOption {
        type = types.str;
        example = "root:root";
        description = "Owner of downloaded files";
      };
      dir = mkOption {
        type = types.str;
        example = "/home/user/Downloads";
        description = "The directory to download files to";
      };
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;

    systemd.services.tailscaleDownload = mkIf cfg.download.enable {
      description = "Tailscale File Get Service";
      after = [ "tailscaled.service" ];
      partOf = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = "5s";
      };
      unitConfig = {
        StartLimitBurst = 5;
        StartLimitInterval = "30s";
      };
      script = ''
        set -euo pipefail

        while true; do
          mkdir -p ${cfg.download.dir}

          ${pkgs.tailscale}/bin/tailscale file get \
            --verbose --wait --conflict=rename ${cfg.download.dir}

          chown -R ${cfg.download.owner} ${cfg.download.dir}
        done
      '';
    };
  };
}
