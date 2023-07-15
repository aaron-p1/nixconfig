{ lib, ... }: {
  imports = [
    ./alacritty.nix
    ./chromium.nix
    ./direnv.nix
    ./easyeffects.nix
    ./eww.nix
    ./firefox.nix
    ./git.nix
    ./gpg.nix
    ./hyprland.nix
    ./idea-ultimate.nix
    ./libreoffice.nix
    ./mpv.nix
    ./neovim.nix
    ./obs-studio.nix
    ./plasma.nix
    ./ssh.nix
    ./tmux.nix
    ./xdg.nix
    ./zathura.nix
    ./zsh.nix
  ];

  options.within.enableEncryptedFileOptions = with lib;
    mkOption {
      type = types.bool;
      default = true;
      description =
        "disable all options that require decryption of inline-secrets";
    };
}
