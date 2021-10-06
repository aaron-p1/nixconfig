{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
  ];

  programs.java.enable = true;

  home.file.".jdks/openjdk-11".source = pkgs.jdk11;
}
