{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  _class = "nixos";

  imports = [
    ./graphics
    ./networking

    ./bluetooth.nix
    ./boot.nix
    ./containers.nix
    ./less.nix
    ./locale.nix
    ./man.nix
    ./nix.nix
    ./ssh.nix
    ./pam.nix
    ./audio.nix
    ./samba.nix
    ./steam.nix
    ./swap.nix
    ./tailscale.nix
    ./uxplay.nix

    ./users.nix
    ./responsiveness.nix
  ];

  options.within.enableEncryptedFileOptions = mkOption {
    type = types.bool;
    default = true;
    description = "disable all options that require decryption of inline-secrets";
  };
}
