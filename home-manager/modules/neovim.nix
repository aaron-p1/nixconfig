{ config, lib, pkgs, ... }:
let cfg = config.within.neovim;
in with lib; {
  options.within.neovim = { enable = mkEnableOption "Neovim"; };

  config = mkIf cfg.enable {
    # TODO change to package with dependency list
    # then for each input replace @varName@: --subst-var-by <varName> <s>
    home.packages = with pkgs; [
      neovim-nightly
      xsel
      # nvim tree
      nerdfonts

      (pkgs.writeShellScriptBin "update-neovim-packer" ''
        nix shell "nixpkgs#"{python3,gnumake,unzip,gcc} --command nvim "+PackerSync"
      '')
    ];

    xdg.configFile."nvim" = {
      source = pkgs.dotfiles.nvim;
      recursive = true;
    };
  };
}
