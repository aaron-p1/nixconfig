{ config, lib, pkgs, ... }:
let
  imports = [
      ../modules/xdg.nix
      ../modules/zsh.nix
      ../modules/direnv.nix
      ../modules/neovim.nix
      ../modules/gpg.nix
      ../modules/git.nix
  ];

  cli-packages = with pkgs; [
    jq
  ];
  productivity = with pkgs; [
    firefox
  ];
  home-packages = cli-packages;
in
  {
    inherit imports;
    home.packages = home-packages;

    home.sessionVariables = {
      EDITOR = "nvim";
    };
    
  }
