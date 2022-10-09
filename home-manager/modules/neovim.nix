{ config, lib, pkgs, ... }:
let cfg = config.within.neovim;
in with lib; {
  options.within.neovim = { enable = mkEnableOption "Neovim"; };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ neovim-nightly ];

    xdg.configFile."nvim" = {
      source = pkgs.dotfiles.nvim;
      recursive = true;
    };
  };
}
