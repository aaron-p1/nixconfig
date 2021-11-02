{ pkgs, ... }:
{
  services.xserver = {
    enable = true;

    desktopManager.plasma5 = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    local.latte-dock
  ];
}
