{ config, lib, pkgs, inputs, ... }:
let
  inherit (lib) mkEnableOption mkOption mkIf types concatStringsSep optional;

  cfg = config.within.nix;
in {
  options.within.nix = {
    enable = mkEnableOption "nix config";
    emulatedSystems = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "emulated systems with qemu";
    };
    enablei686 = mkEnableOption "i686 platform";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.latest;
      extraOptions = ''
        experimental-features = nix-command flakes auto-allocate-uids
        extra-platforms = ${
          concatStringsSep " "
          ((optional cfg.enablei686 "i686-linux") ++ cfg.emulatedSystems)
        }
        keep-outputs = true
        keep-derivations = true
      '';
      # Set nixpkgs channel to follow flake
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      settings = {
        trusted-users = [ "root" ];

        substituters = [ "https://nix-community.cachix.org/" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        auto-optimise-store = true;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 15d";
        dates = "monthly";
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "electron-25.9.0" ];
    };

    boot.binfmt.emulatedSystems = cfg.emulatedSystems;

    environment.systemPackages = [
      pkgs.nix-output-monitor

      # nix shell nixpkgs#{$1}
      (pkgs.writeShellScriptBin "s" ''
        if [ -z "$1" ]
        then
          echo "Usage: $0 {nixpkg}" 1>&2
          exit 1
        fi

        pkg="$1"
        shift

        NIXPKGS_ALLOW_UNFREE=1 exec nix shell --impure "nixpkgs#$pkg" -- "$@"
      '')

      # nix run nixpkgs#{$1}
      (pkgs.writeShellScriptBin "x" ''
        if [ -z "$1" ]
        then
          echo "Usage: $0 {nixpkg}" 1>&2
          exit 1
        fi

        pkg="$1"
        shift

        NIXPKGS_ALLOW_UNFREE=1 exec nix --quiet run --impure "nixpkgs#$pkg" -- "$@"
      '')
    ];
  };
}
