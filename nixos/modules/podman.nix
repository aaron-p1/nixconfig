{ pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    enableNvidia = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
