{ config, lib, pkgs, inputs, ... }:
let cfg = config.within.nix;
in with lib; {
  options.within.nix = {
    enable = mkEnableOption "nix config";
    emulatedSystems = mkOption {
      type = with types; listOf str;
      default = [ ];
      description = "emulated systems with qemu";
    };
    enablei686 = mkEnableOption "i686 platform";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        extra-platforms = ${optionalString cfg.enablei686 "i686-linux "}${
          concatStringsSep " " cfg.emulatedSystems
        }
        keep-outputs = true
        keep-derivations = true
      '';
      # Set nixpkgs channel to follow flake
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      settings = {
        trusted-users = [ "root" "@wheel" ];

        substituters = [ "https://nix-community.cachix.org/" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        auto-optimise-store = true;
      };

      gc = {
        automatic = true;
        options = "--delete-older-than 15d";
        dates = "weekly";
      };
    };

    nixpkgs.config = {
      allowUnfree = true;
      permittedInsecurePackages = [ ];
    };

    boot.binfmt.emulatedSystems = cfg.emulatedSystems;
  };
}
