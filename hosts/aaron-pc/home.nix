{ pkgs, ... }: {
  within.git.signingKey = "59C3DF25ECE049B6!";

  home.packages = with pkgs; [
    kalendar
  ];
}
