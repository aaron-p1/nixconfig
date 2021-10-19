{ config, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim-nightly
    # used in telescope
    fd
    ripgrep
    # used in nvim tree
    nerdfonts
    # lsp
    rnix-lsp
    shellcheck
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
