{ pkgs, inputs, ... }:
{
  nix = {
    package = pkgs.nixUnstable;
    trustedUsers = [ "root" "@wheel" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # Set nixpkgs channel to follow flake
    registry.nixpkgs.flake = inputs.unstable;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
      dates = "weekly";
    };
  };

  nixpkgs.config.allowUnfree = true;
}
