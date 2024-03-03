{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.within.neovim;
in {
  options.within.neovim = { enable = mkEnableOption "Neovim"; };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.neovim-nightly
      (pkgs.neovim-remote.overrideAttrs (attrs:
        attrs // {
          patches = attrs.patches ++ [
            (pkgs.fetchpatch {
              url = "https://github.com/mhinz/neovim-remote/pull/190.patch";
              sha256 = "sha256-BGaysA9pKxAbBhQFzdpUn1qA8wWZOVhUJ4x2sClgwwc=";
            })
          ];
        }))
    ];

    xdg.configFile."nvim" = {
      source = pkgs.dotfiles.nvim;
      recursive = true;
    };
  };
}
