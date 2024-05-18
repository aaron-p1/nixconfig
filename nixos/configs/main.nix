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
      networkDomains = { };

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

    # ../modules/less.nix
    less.enable = true;

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
    pam.u2f = {
      enable = true;

      autolock = {
        enable = true;
        user = "aaron";
      };
    };

    # ../modules/samba.nix
    samba.enable = false;

    # ../modules/syncthing.nix
    syncthing = {
      enable = false;
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

    # ../modules/tailscale.nix
    tailscale = {
      enable = true;
      download = {
        enable = true;
        owner = "aaron:users";
        dir = "/home/aaron/Downloads/Tailscale";
      };
    };

    monitoring.enable = false;
  };

  systemd.extraConfig = ''
    DefaultTimeoutStartSec=30s
    DefaultTimeoutStopSec=30s
  '';

  hardware.keyboard.zsa.enable = true;

  programs = {
    zsh.enable = true;
    ausweisapp.enable = false;
    dconf.enable = true;

    nix-ld.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      htop
      git
      wget
      neovim

      anki

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

  fonts.packages = with pkgs; [
    corefonts
    source-han-sans
    kanji-stroke-order-font
  ];

  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "100%";
  };

  services = {
    journald.extraConfig = "SystemMaxUse=1G";
    smartd.enable = true;
    # for yubikey pgp configuration
    pcscd.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    restic.backups.documentsRemote = {
      paths = [ "/home/aaron/Documents" ];
      repository = "rest:http://home-server:54321";
      passwordFile = "/etc/secrets/restic_remote";
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };

  security.pki.certificateFiles = [ ./files/home-server.crt ];
}
