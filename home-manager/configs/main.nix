{ pkgs, ... }: {
  imports = [ ../modules ];

  within = {
    # ../modules/xdg.nix
    xdg = {
      enable = true;
      desktopEntries = {
        enable = true;
        terminal = {
          nixconfig = true;
          oro = true;
        };
        links.nixpkgs = true;
      };
    };

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
    easyeffects.enable = false;

    # ../modules/firefox.nix
    firefox.enable = true;

    # ../modules/gpg.nix
    gpg.enable = true;

    # ../modules/git.nix
    git.enable = true;

    # ../modules/neovim.nix
    neovim.enable = false;

    # ../modules/neovim-new
    neovim-new.enable = true;

    # ../modules/mpv.nix
    mpv.enable = true;

    # ../modules/zathura.nix
    zathura.enable = true;

    # ../modules/obs-studio.nix
    obs-studio.enable = true;

    # ../modules/idea-ultimate.nix
    idea-ultimate.enable = false;

    # ../modules/libreoffice.nix
    libreoffice.enable = false;

    # ../modules/plasma.nix
    plasma.enableKWallet = false;

    # ../modules/shell-scripts.nix
    shellScripts.enable = true;
  };

  home = {
    sessionVariables.EDITOR = "nvim";

    packages = with pkgs; [
      gnumake
      wl-clipboard

      hunspell
      hunspellDicts.en_US
      hunspellDicts.de_DE

      tdesktop
      discord
      thunderbird
      qalculate-gtk
      gImageReader
      feh
      obsidian
      bitwarden

      local.create-project
      local.nix-autobahn
      local.ask
    ];

    stateVersion = "18.09";
  };
}
