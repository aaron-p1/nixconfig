{ pkgs, inputs, ... }:
{
  nix = {
    package = pkgs.nixUnstable;
    trustedUsers = [ "root" "@wheel" ];
    extraOptions = ''
      experimental-features = nix-command flakes
      extra-platforms = aarch64-linux
    '';
    # Set nixpkgs channel to follow flake
    registry.nixpkgs.flake = inputs.unstable;

    autoOptimiseStore = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 15d";
      dates = "weekly";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
