{ lib, ... }: {
  imports = [
    ./graphics
    ./monitoring
    ./networking

    ./bluetooth.nix
    ./boot.nix
    ./containers.nix
    ./less.nix
    ./locale.nix
    ./mysql.nix
    ./nix.nix
    ./ssh.nix
    ./pam.nix
    ./audio.nix
    ./samba.nix
    ./specialisation.nix
    ./steam.nix
    ./swap.nix
    ./syncthing.nix
    ./tailscale.nix
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
