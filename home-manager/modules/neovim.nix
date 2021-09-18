{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim-nightly
    fd # used in telescope
    (
      pkgs.writeTextFile rec {
        name = "update-neovim-packer";
        destination = "/bin/${name}";
        executable = true;
        text = ''
          #!/bin/sh

          nix shell "nixpkgs#"{python3,gnumake,unzip} --command nvim "+PackerSync"
        '';
      }
    )
  ];

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
