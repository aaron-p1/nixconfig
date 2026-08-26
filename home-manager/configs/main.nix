{ pkgs, osConfig, ... }:
{
  _class = "homeManager";

  imports = [ ../modules ];

  within = {
    # ../modules/xdg.nix
    xdg.enable = true;

    # ../modules/ssh.nix
    ssh.enable = true;

    # ../modules/zsh.nix
    zsh.enable = true;

    # ../modules/tmux.nix
    tmux.enable = false;

    # ../modules/alacritty.nix
    alacritty.enable = true;

    # ../modules/ghostty/default.nix
    ghostty.enable = true;

    # ../modules/direnv.nix
    direnv.enable = true;

    # ../modules/firefox.nix
    firefox.enable = true;

    # ../modules/gpg.nix
    gpg.enable = true;

    # ../modules/git.nix
    git = {
      enable = true;
      signingKey = "E4D6E854DD2D5799!";
    };

    # ../modules/neovim/default.nix
    neovim.enable = true;

    # ../modules/mpv.nix
    mpv.enable = true;

    # ../modules/zathura.nix
    zathura.enable = true;

    # ../modules/shell-scripts.nix
    shellScripts.enable = true;

    # ../modules/nsxiv/default.nix
    nsxiv.enable = true;
  };

  home = {
    sessionVariables.EDITOR = "nvim";

    packages = with pkgs; [
      gnumake
      wl-clipboard

      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_DE

      anki

      telegram-desktop
      thunderbird
      qalculate-gtk
      gImageReader
      lunatask
    ];

    stateVersion = "21.05";
  };

  nix.gc = {
    inherit (osConfig.nix.gc) automatic options dates;
  };

  # silence warnings because of old stateVersion
  programs.swaylock.enable = false;
}
