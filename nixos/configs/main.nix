{ pkgs, config, ... }:
{
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

      bindAddrsV4 = {
        exo = "127.32.0.2";
        exo-wp = "127.32.0.3";
        scrapp = "127.32.0.5";
      };

      dnscrypt = {
        enable = true;
        cloak = {
          exo-wp = "127.32.0.3";
        };
      };

      devService = {
        enable = true;
        services = {
          exo.ip = config.within.networking.bindAddrsV4.exo;
          scrapp = {
            ip = config.within.networking.bindAddrsV4.scrapp;
            redirectRoot = "http://system.scrapp.dev.home.arpa";
          };
        };
      };
    };

    # ../modules/users.nix
    users.aaron = {
      uid = 1000;

      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHH+KaiMdH9pUqDNkKCcChE74HFQ3Es76jWeHLEpelBe iPhone Termius"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUW3ZgzN7QomJwZAgKrvVeex4CkhZbQCcBlcZ33GatS iPhone Shortcuts"

        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJD03U205n7+0gD/PVRywPVssw7av+xBKwWPkbBYADhjAAAABHNzaDo= pc key1"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIF3nvIpcbZKmuZppJ09X20XO7XVzBK53UKVKKr9S/H7kAAAABHNzaDo= pc key2"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIdjsIDNKVQ6NiHZv3CCrDavz/xxXcEGEyWjH9WStIR pc passwd"

        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIL3Gk0WVEKfUpcjzmqcjN7qFfLfct9WcxmX92PiQiN9wAAAABHNzaDo= laptop key1"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIB55Q4HD6/QkaIBqFo64DG+2cJKke5aVUdNedDb+xoj4AAAABHNzaDo= laptop key2"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAQdpPyCPWclyYxXV2lJLop/gxGiviiKhT68o9UGHePf laptop passwd"

        # import keys on new host: gpg --card-status
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuv8kzAqsJFdoJLM6QAlhwfhB0YLHvii4kBq4LOl/zV yubikey 1"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMSQdmVMLKCz/qjZnaGBpCscQLPwkOQ7x0GGehcWNzwh thinkpad passwd"
      ];

      u2fKeys = [
        # 1
        "xzEKu3DqZ5nV4BCLBLJFWuvbyhdEqeZggTz7nn3GJepg4Eo2B3KVnGf/Ka9mqsGENOGsnCxqg/YJxzjQUWzUEw==,c9xqtRaw4EGdRg+SE1n4jeQ2vBz7yPu3ABbOb1UZh7f+Gm3x6zpjXqIuBOAW5fKUTxMIxKP39GOo3oeJaZTfAw==,es256,+presence"
        # 2
        "563Zjwdc5JL90ka2DxMYMo9Ob5EwfocNF3iD2fwIDxJUOXqCz19G9XkZNewxmSFoM2S1z3MbPDaBIpXXUcH8Rw==,YDCPaZRAmsp4oo7ODK5ulOsou7GNqrPCQ4RGlAxEt5v0aquu0M7M57iJBAnhUBMnza7YlNVZEhnfyeQs1oonIg==,es256,+presence"
      ];
    };

    # ../modules/less.nix
    less.enable = true;

    # ../modules/ssh.nix
    ssh.enable = true;

    # ../modules/man.nix
    man.enable = true;

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

    # ../modules/uxplay.nix
    uxplay.enable = true;
  };

  systemd = {
    settings.Manager = {
      DefaultTimeoutStartSec = "30s";
      DefaultTimeoutStopSec = "30s";
      DefaultLimitNOFILE = "4096:524288";
    };
    user.extraConfig = ''
      DefaultTimeoutStartSec=30s
      DefaultTimeoutStopSec=30s
      DefaultLimitNOFILE=4096:524288
    '';
  };

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
      file
      mediainfo
      neovim
      file
      mediainfo
      jq

      restic

      anki

      local.initdev
    ];
    sessionVariables = {
      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_BIN_HOME = "\${HOME}/.local/bin";
      XDG_DATA_HOME = "\${HOME}/.local/share";

      PATH = [ "\${XDG_BIN_HOME}" ];

      SYSTEMD_PAGER = "${pkgs.less}/bin/less";
      SYSTEMD_PAGERSECURE = 1;
      SYSTEMD_LESS = "FRSM";
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
    # for yubikey-manager (ykman)
    # needs to be disabled because it interferes with git signing
    # pcscd.enable = true;
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
    # for printer discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    restic.backups.documentsRemote = {
      paths = [ "/home/aaron/Documents" ];
      repository = "rest:http://home-server:54321";
      passwordFile = "/etc/secrets/restic_remote";
      inhibitsSleep = true;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      backupPrepareCommand = # bash
        ''
          until systemctl is-active --quiet tailscaled.service
          do
            sleep 5
          done
          sleep 10
        '';
    };
  };

  security.pki.certificateFiles = [ ./files/home-server.crt ];
}
