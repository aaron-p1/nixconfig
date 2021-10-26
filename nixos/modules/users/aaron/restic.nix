{ pkgs, ... }:
{
  services.restic.backups = {
    localbackup = {
      user = "aaron";
      initialize = true;
      passwordFile = "/etc/secrets/restic_local";
      paths = [
        "/home/aaron/Documents"
      ];
      repository = "/mnt/data/backup/restic";
      timerConfig = {
        OnCalendar = "0/3:00"; # every 3 hours (systemd-analyze --iterations=5 "0/3:00")
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    restic
  ];
}
