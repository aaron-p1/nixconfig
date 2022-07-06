{ pkgs, config, ... }: {
  imports = [ ../modules ];

  within = {
    # ../modules/nix.nix
    nix = {
      enable = true;
      emulatedSystems = [ "aarch64-linux" ];
      enablei686 = true;
    };

    # ../modules/locale.nix
    locale.enable = true;

    # ../modules/networking.nix
    networking = {
      enable = true;

      v4.redirectLoopback80 = true;
      v6.redirectLoopback80 = true;

      localDomains = {
        exo = "127.32.0.2";
        sso = "127.32.0.3";
        plat = "127.32.0.4";

        syncthing = "127.32.0.101";
      };
      networkDomains = { public-server = "192.168.178.8"; };

      dns = "blocky";

      nameservers = [
        "https://dns.quad9.net/dns-query"
        "https://dns.digitale-gesellschaft.ch/dns-query"
        "https://dnsforge.de/dns-query"
      ];

      nm = {
        enable = true;
        dns = "none";
      };

      blocky.blockListFile =
        [ ../../secrets/inline-secrets/blocked-domains.txt ];
    };

    # ../modules/users.nix
    users.aaron = {
      uid = 1000;

      sshKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB668EmES2fAD6UVJEEAZCpbzX4Tu/S2dOfIG9ncuqIWyCBNz0IQfE+rGqwdpkjoagp5sy7V5OqSZLCct0IDMX9DrtSq1ucxSib14lmuKm6b1BhHMhexC7XSjmpn0QWAtmhaLz0P8eEsO+V3BWz6aNRZKhJ+1FmI3yKgQ5B2Et5UrZ2l0v0d/Pw799uhO0P+JGPYyWwHEWK2+vT1bHP9c/xjs37SnNrFv/EEWRiP55J8e2htNpJsDbmwi933Vg1UU+PJCp/g4m5O98pY6xOOp6bKC2mOHHwwGoWeX2yXvwHB62UqCspssoBg4GYkdu8/szrR1MEjbIXGDiermKoaWym/efJOEgNqM1aZTx8ojp5K8oveVOt7UrReLmbopQuz13y8mftv9CSvAjC7DTgqgb0ncRYfh1jgLOUjojejqkZ7wT3BC2/koP3VqZDVCb4qLN56juGWnApjgrAyKW7lSZ+++lw+mblwj0Zd6kKspoend1vSLtYQTKUpSEoLPCiWVJAM7pAcA5oup47iRfkOWHb5/mhfPL3soVO2AAf0z5aBO5curtuYDbgLle6KdWXfuzp6bDrwTsaGa0Sti0fDFuVERQvWixAY86b92P2GJwamK1s/los3Pvs4GjkdlrY5O6FuYVpYaPTWrJuAzu5Qp3SLbyvLHM5zvR31Q4t0+MRw== iPhone Terminus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUW3ZgzN7QomJwZAgKrvVeex4CkhZbQCcBlcZ33GatS iPhone Shortcuts"

        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJD03U205n7+0gD/PVRywPVssw7av+xBKwWPkbBYADhjAAAABHNzaDo= aaron@aaron-pc key1"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIF3nvIpcbZKmuZppJ09X20XO7XVzBK53UKVKKr9S/H7kAAAABHNzaDo= aaron@aaron-pc key2"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIdjsIDNKVQ6NiHZv3CCrDavz/xxXcEGEyWjH9WStIR aaron@aaron-pc passwd"
      ];
    };

    # ../modules/ssh.nix
    ssh.enable = true;

    # ../modules/graphics/default.nix
    graphics = {
      xserver.enable = true;
      sddm.enable = true;
      plasma = {
        enable = true;
        kdeConnect = true;
      };
    };

    # ../modules/bluetooth.nix
    bluetooth.enable = true;

    # ../modules/pipewire.nix
    audio.pipewire.enable = true;

    # ../modules/containers.nix
    containers = {
      enable = true;
      podman = true;
    };

    # ../modules/pam.nix
    pam.u2f.enable = true;

    # ../modules/samba.nix
    samba.enable = true;

    # ../modules/syncthing.nix
    syncthing = {
      enable = true;
      user = "aaron";
      group = "users";
      guiAddress = "${config.within.networking.localDomains.syncthing}:8000";
      deviceIDFile = ../../secrets/inline-secrets/syncthing-device-ids.json;

      folders = {
        thl = {
          path = "/home/aaron/Documents/thl";
          ignorePerms = false;
          versioning = {
            type = "simple";
            params.keep = "3";
          };
        };
        work = {
          path = "/home/aaron/Documents/work/";
          ignorePerms = false;
          versioning = {
            type = "simple";
            params.keep = "3";
          };
        };
      };
    };

    # ../modules/steam.nix
    steam.enable = true;

    monitoring.enable = true;
  };

  hardware.keyboard.zsa.enable = true;

  programs = { dconf.enable = true; };

  environment = {
    systemPackages = with pkgs; [
      git
      wget
      neovim-nightly

      local.initdev
    ];
    sessionVariables = {
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_BIN_HOME = "\${HOME}/.local/bin";
      XDG_DATA_HOME = "\${HOME}/.local/share";

      PATH = [ "\${XDG_BIN_HOME}" ];
    };
  };

  fonts.fonts = with pkgs; [ corefonts ];

  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "100%";

  services = {
    journald.extraConfig = "SystemMaxUse=1G";
    smartd.enable = true;
  };
}
