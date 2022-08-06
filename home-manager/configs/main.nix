{ pkgs, ... }: {
  imports = [ ../modules ];

  within = {
    # ../modules/xdg.nix
    xdg.enable = true;

    # ../modules/ssh.nix
    ssh.enable = true;

    # ../modules/zsh.nix
    zsh.enable = true;

    # ../modules/tmux.nix
    tmux.enable = true;

    # ../modules/alacritty.nix
    alacritty.enable = true;

    # ../modules/direnv.nix
    direnv.enable = true;

    # ../modules/easyeffects.nix
    easyeffects.enable = true;

    # ../modules/firefox.nix
    firefox.enable = true;

    # ../modules/gpg.nix
    gpg.enable = true;

    # ../modules/git.nix
    git.enable = true;

    # ../modules/neovim.nix
    neovim.enable = true;

    # ../modules/mpv.nix
    mpv.enable = true;

    # ../modules/zathura.nix
    zathura.enable = true;

    # ../modules/obs-studio.nix
    obs-studio.enable = true;

    # ../modules/idea-ultimate.nix
    idea-ultimate.enable = true;

    # ../modules/libreoffice.nix
    libreoffice.enable = true;
  };

  home.sessionVariables = { EDITOR = "nvim"; };

  services.kdeconnect.enable = true;

  home.packages = with pkgs; [
    gnumake

    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE

    tdesktop
    discord
    thunderbird
    qalculate-gtk
    flameshot
    gImageReader
    ark
    obsidian
    element-desktop
    bitwarden

    local.nix-autobahn
  ];

  home.stateVersion = "18.09";
}
