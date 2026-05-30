{
  pkgs,
  osConfig,
  lib,
  ...
}:
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

    # ../modules/direnv.nix
    direnv.enable = true;

    # ../modules/firefox.nix
    firefox.enable = true;

    # ../modules/gpg.nix
    gpg.enable = true;

    # ../modules/git.nix
    git = {
      enable = true;
      signingKey = "B19562BBEF50FD55!";
    };

    # ../modules/neovim/default.nix
    neovim.enable = true;

    # ../modules/mpv.nix
    mpv.enable = true;

    # ../modules/zathura.nix
    zathura.enable = true;

    # ../modules/obs-studio.nix
    obs-studio.enable = false;

    # ../modules/idea-ultimate.nix
    idea-ultimate.enable = false;

    # ../modules/libreoffice.nix
    libreoffice.enable = false;

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

  # not working yet because cosmic overrides QT_QPA_PLATFORMTHEME
  qt = lib.mkIf (osConfig.services.desktopManager.cosmic.enable == true) {
    enable = true;
    platformTheme.name = "qtct";
    style = {
      name = "Breeze";
    };
  };
}
