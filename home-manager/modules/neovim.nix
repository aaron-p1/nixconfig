{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim-nightly
    fd # used in telescope
    nerdfonts # used in nvim tree
    (
      pkgs.writeTextFile rec {
        name = "update-neovim-packer";
        destination = "/bin/${name}";
        executable = true;
        text = ''
          #!/bin/sh

          nix shell "nixpkgs#"{python3,gnumake,unzip,gcc} --command nvim "+PackerSync"
        '';
      }
    )
  ];

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
