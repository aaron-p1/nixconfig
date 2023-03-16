{ pkgs, config, ... }: {
  imports = [ ../modules ];

  within = {
    # ../modules/swap.nix
    swap.zram = 80;

    # ../modules/nix.nix
    nix = {
      enable = true;
      emulatedSystems = [ "aarch64-linux" ];
      enablei686 = true;
    };

    # ../modules/locale.nix
    locale.enable = true;

    # ../modules/networking/default.nix
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
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDxODlfZI53dTGjJ+Qze1XNHH0Tkm3wrd1kOLYiU48s2 iPhone Termius"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUW3ZgzN7QomJwZAgKrvVeex4CkhZbQCcBlcZ33GatS iPhone Shortcuts"

        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJD03U205n7+0gD/PVRywPVssw7av+xBKwWPkbBYADhjAAAABHNzaDo= pc key1"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIF3nvIpcbZKmuZppJ09X20XO7XVzBK53UKVKKr9S/H7kAAAABHNzaDo= pc key2"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIdjsIDNKVQ6NiHZv3CCrDavz/xxXcEGEyWjH9WStIR pc passwd"

        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL3Gk0WVEKfUpcjzmqcjN7qFfLfct9WcxmX92PiQiN9wAAAABHNzaDo= laptop key1"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB55Q4HD6/QkaIBqFo64DG+2cJKke5aVUdNedDb+xoj4AAAABHNzaDo= laptop key2"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQdpPyCPWclyYxXV2lJLop/gxGiviiKhT68o9UGHePf laptop passwd"
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
        inputMethod.japanese = true;
      };

      hyprland = {
        enable = true;
        nvidia = true;
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

  programs = {
    ausweisapp = {
      enable = true;
      openFirewall = true;
    };
    dconf.enable = true;
  };

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

  fonts.fonts = with pkgs; [ corefonts source-han-sans ];

  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "100%";

  services = {
    journald.extraConfig = "SystemMaxUse=1G";
    smartd.enable = true;
    # for yubikey pgp configuration
    pcscd.enable = true;
    flatpak.enable = true;
  };
}
