{ pkgs, ... }: {
  within = {
    git.signingKey = "F524AC445FF173DB!";

    hyprland.monitorFallback = ",highrr,auto,1";
  };

  home.packages = with pkgs; [ kalendar virt-manager ];
}
