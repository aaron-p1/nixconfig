{ config, lib, pkgs, ... }:
let
  imports = [
      ../modules/xdg.nix
      ../modules/zsh.nix
      ../modules/direnv.nix
      ../modules/easyeffects.nix
      # cli tools
      ../modules/neovim.nix
      ../modules/gpg.nix
      ../modules/git.nix
      ../modules/tmux.nix
      # gui programs
      ../modules/firefox.nix
      ../modules/alacritty.nix
  ];

  cli-packages = with pkgs; [
  ];
  gui-packages = with pkgs; [
    tdesktop
    discord
    thunderbird
  ];
  font-packages = with pkgs; [
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
