{ lib, ... }: {
  imports = [
    ./graphics
    ./networking

    ./bluetooth.nix
    ./boot.nix
    ./containers.nix
    ./locale.nix
    ./nix.nix
    ./ssh.nix
    ./pam.nix
    ./audio.nix
    ./samba.nix
    ./steam.nix
    ./swap.nix
    ./syncthing.nix
    ./vmclient.nix

    ./users.nix
  ];

  options.within.enableEncryptedFileOptions = with lib;
    mkOption {
      type = types.bool;
      default = true;
      description =
        "disable all options that require decryption of inline-secrets";
    };
}
