{ config, lib, pkgs, ... }:
let
  imports = [
      ../modules/xdg.nix
      ../modules/zsh.nix
      ../modules/direnv.nix
      # cli tools
      ../modules/neovim.nix
      ../modules/gpg.nix
      ../modules/git.nix
      # gui programs
      ../modules/firefox.nix
      ../modules/alacritty.nix
  ];

  cli-packages = with pkgs; [
  ];
  gui-packages = with pkgs; [
  ];
  font-packages = with pkgs; [
    nerdfonts
  ];
  home-packages = cli-packages ++ gui-packages ++ font-packages;
in
  {
    inherit imports;
    home.packages = home-packages;

    home.sessionVariables = {
      EDITOR = "nvim";
    };
    
  }
