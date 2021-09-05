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

          nix-shell -p python3 gnumake unzip --run "nvim +PackerSync"
        '';
      }
    )
  ];

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
