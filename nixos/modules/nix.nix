{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.within.nix;
in
with lib; {
  options.within.nix = {
    enable = mkEnableOption "nix config";
    emulatedSystems = mkOption {
      type = with types; listOf str;
      default = [];
      description = "emulated systems with qemu";
    };
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixUnstable;
      trustedUsers = [ "root" "@wheel" ];
      extraOptions = ''
        experimental-features = nix-command flakes
        extra-platforms = ${concatStringsSep " " cfg.emulatedSystems}
      '';
      # Set nixpkgs channel to follow flake
      registry.nixpkgs.flake = inputs.unstable;

      binaryCaches = [
        "https://nix-community.cachix.org/"
      ];

      binaryCachePublicKeys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      autoOptimiseStore = true;

      gc = {
        automatic = true;
        options = "--delete-older-than 15d";
        dates = "weekly";
      };
    };

    nixpkgs.config.allowUnfree = true;

    boot.binfmt.emulatedSystems = cfg.emulatedSystems;
  };
}
