{ pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.idea-ultimate
  ];

  programs.java.enable = true;

  home.file.".jdks/openjdk-11".source = pkgs.jdk11;
  home.file.".jdks/openjdk-8".source = pkgs.jdk8;
}
