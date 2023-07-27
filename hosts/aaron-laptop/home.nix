{ pkgs, ... }: {
  within.git.signingKey = "F524AC445FF173DB!";
  home.packages = with pkgs; [
    virt-manager
  ];
}
