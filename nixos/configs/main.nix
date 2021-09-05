{ pkgs, inputs, ... }:
{
  imports = [
    ../modules/sway.nix
    ../modules/pipewire.nix
  ];

  time.timeZone = "Europe/Berlin";

  # NETWORKING
  networking.useDHCP = false; # deprecated
  networking.interfaces.enp1s0.useDHCP = true;

  # LOCALE
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  # NIX
  nix = {
    package = pkgs.nixUnstable;
    trustedUsers = [ "root" "aaron" "@wheel" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # Set nixpkgs channel to follow flake
    registry.nixpkgs.flake = inputs.stable;
  };

  nixpkgs.config.allowUnfree = true;

  # PACKAGES
  environment.systemPackages = with pkgs; [
    git
    wget
    neovim-nightly
  ];

  # GC
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";

  # USER
  users.users.aaron = {
    isNormalUser = true;
    createHome = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 25566 ];
    permitRootLogin = "no";
  };
}
