{ pkgs, ... }: {
  within = {
    git.signingKey = "F524AC445FF173DB!";
    ssh.keyFiles =
      [ "~/.ssh/id_ed25519_sk" "~/.ssh/id_ed25519_sk_2" "~/.ssh/id_ed25519" ];

    hyprland.monitorFallback = ",highrr,auto,1";
  };

  home.packages = with pkgs; [ kalendar virt-manager ];
}
