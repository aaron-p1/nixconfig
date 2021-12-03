{ pkgs, ... }:
{
  imports = [
    ../modules
  ];

  within = {
    # ../modules/nix.nix
    nix = {
      enable = true;
      emulatedSystems = [ "aarch64-linux" ];
    };

    # ../modules/locale.nix
    locale.enable = true;

    # ../modules/networking.nix
    networking = {
      enable = true;
      firewall = true;
      nm = {
        enable = true;
        dnsmasq = {
          enable = true;
          localDomains = {
            exo = "127.32.0.2";
          };
          networkDomains = {
            public-server = "192.168.178.8";
          };
        };
      };
    };

    # ../modules/users.nix
    users.aaron = {
      uid = 1000;

      sshKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDB668EmES2fAD6UVJEEAZCpbzX4Tu/S2dOfIG9ncuqIWyCBNz0IQfE+rGqwdpkjoagp5sy7V5OqSZLCct0IDMX9DrtSq1ucxSib14lmuKm6b1BhHMhexC7XSjmpn0QWAtmhaLz0P8eEsO+V3BWz6aNRZKhJ+1FmI3yKgQ5B2Et5UrZ2l0v0d/Pw799uhO0P+JGPYyWwHEWK2+vT1bHP9c/xjs37SnNrFv/EEWRiP55J8e2htNpJsDbmwi933Vg1UU+PJCp/g4m5O98pY6xOOp6bKC2mOHHwwGoWeX2yXvwHB62UqCspssoBg4GYkdu8/szrR1MEjbIXGDiermKoaWym/efJOEgNqM1aZTx8ojp5K8oveVOt7UrReLmbopQuz13y8mftv9CSvAjC7DTgqgb0ncRYfh1jgLOUjojejqkZ7wT3BC2/koP3VqZDVCb4qLN56juGWnApjgrAyKW7lSZ+++lw+mblwj0Zd6kKspoend1vSLtYQTKUpSEoLPCiWVJAM7pAcA5oup47iRfkOWHb5/mhfPL3soVO2AAf0z5aBO5curtuYDbgLle6KdWXfuzp6bDrwTsaGa0Sti0fDFuVERQvWixAY86b92P2GJwamK1s/los3Pvs4GjkdlrY5O6FuYVpYaPTWrJuAzu5Qp3SLbyvLHM5zvR31Q4t0+MRw== iPhone Terminus"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUW3ZgzN7QomJwZAgKrvVeex4CkhZbQCcBlcZ33GatS iPhone Shortcuts"
      ];

      u2fKeys = [
        # yubikey ..9
        "Mb3DZGUsu4lhdja3HFiITo8bVdlYSSCisnNaXUukK0hLeIuHp7xHf7QFP/2VTwVei23pVNT9e3wE/eX1JJSkUQ==,Xu6hTKJhHgVU7Z3hIzqBhst3E0xW4J/MudMPLhruK4XFhIr74y69D9Z0aCsFZQ6YOcE0rk+4yTFSQhu/bR2S7A==,es256,+presence"
        # yubikey ..2
        "LV/FPWrKyNQBfWhHDGxXVZkx/LDoW+EJKV65A28igjqqGKPGJ7PWWEQlNtumOy6b0C2WHYXo9MeSbqQboAs98w==,dSfmZDimcp1x3ttEM9sBCd7/fBE+EZ2aoboLx9GR/YIfJCyU/DWH7t+6vWQv8MzxL5mjZOjboGHoUrnCxCopvQ==,es256,+presence"
      ];

      resticBackup = {
        enable = true;
        paths = [
          "/home/aaron/Documents"
        ];

        repository = "/mnt/data/backup/restic";
      };
    };

    # ../modules/ssh.nix
    ssh.enable = true;

    # ../modules/graphics/default.nix
    graphics = {
      xserver.enable = true;
      sddm.enable = true;
      plasma.enable = true;
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

    # ../modules/steam.nix
    steam.enable = true;
  };

  programs = {
    dconf.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    wget
    neovim-nightly
  ];

  boot.cleanTmpDir = true;
}
