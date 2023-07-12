{ pkgs, ... }: {
  within = {
    git.signingKey = "14E080A7466A0E0C!";

    hyprland.monitorFallback = ",highrr,auto,1";
  };

  home.packages = with pkgs; [ kalendar virt-manager ];
}
