_: {
  _class = "nixos";

  imports = [
    ./dms-niri.nix
    ./gdm.nix
    ./plasma.nix
    ./sddm.nix
    ./xserver.nix
  ];
}
