{ lib, ... }:
let inherit (lib) mkOption types;
in {
  imports = [
    ./alacritty.nix
    ./chromium.nix
    ./direnv.nix
    ./easyeffects.nix
    ./firefox.nix
    ./git.nix
    ./gpg.nix
    ./idea-ultimate.nix
    ./kde-service-menus
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

  options.within.enableEncryptedFileOptions = mkOption {
    type = types.bool;
    default = true;
    description =
      "disable all options that require decryption of inline-secrets";
  };
}
