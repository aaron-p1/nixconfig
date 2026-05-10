_: {
  _class = "nixos";

  imports = [
    ./cosmic.nix
    ./dms-niri.nix
    ./gdm.nix
    ./plasma.nix
    ./sddm.nix
    ./xserver.nix
  ];
}
