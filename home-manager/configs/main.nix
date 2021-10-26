{ config, lib, pkgs, ... }:
let
  imports = [
    ../modules/xdg.nix
    ../modules/zsh.nix
    ../modules/ssh.nix
    ../modules/direnv.nix
    ../modules/easyeffects.nix
    # cli tools
    ../modules/neovim.nix
    ../modules/gpg.nix
    ../modules/git.nix
    ../modules/tmux.nix
    ../modules/mpv.nix
    # gui programs
    ../modules/firefox.nix
    ../modules/alacritty.nix
    ../modules/idea-ultimate.nix
    ../modules/zathura.nix
    ../modules/obs-studio.nix
  ];

  cli-packages = with pkgs; [
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE
  ];
  gui-packages = with pkgs; [
    tdesktop
    discord
    thunderbird
    qalculate-gtk
    flameshot
    gImageReader
    gtg
    ark

    multimc
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
