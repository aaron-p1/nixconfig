{ pkgs, ... }: {
  # TODO change to package with dependency list
  # then for each input replace @varName@: --subst-var-by <varName> <s>
  home.packages = with pkgs; [
    neovim-nightly
    xsel
    # telescope
    fd
    ripgrep
    # nvim tree
    nerdfonts
    # lsp
    rnix-lsp
    # null-ls
    shellcheck
    shfmt
    shellharden
    nixfmt
    statix
    # java
    local.jdt-language-server

    (pkgs.writeShellScriptBin "update-neovim-packer" ''
      nix shell "nixpkgs#"{python3,gnumake,unzip,gcc} --command nvim "+PackerSync"
    '')
  ];

  xdg.configFile."nvim" = {
    source = ../../dotfiles/nvim;
    recursive = true;
  };
}
