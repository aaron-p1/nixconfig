{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.steam;
in {
  options.within.steam = { enable = mkEnableOption "Steam"; };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;

      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
    };

    environment.systemPackages = [
      (pkgs.writeTextFile {
        name = "aftersteam";
        destination = "/bin/aftersteam";
        executable = true;
        text = ''
          #!${pkgs.bash}/bin/bash

          while ${pkgs.procps}/bin/pgrep steamwebhelper > /dev/null
          do
            echo "$(${pkgs.coreutils}/bin/date "+%Y-%m-%d %H:%M:%S"): Still Running, waiting 10s"
            sleep 10
          done

          echo "Stopped, waiting 3s"
          sleep 3
        '';
      })
    ];
  };
}
