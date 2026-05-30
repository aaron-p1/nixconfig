_: {
  _class = "nixos";

  imports = [
    ./dms-niri.nix
    ./plasma.nix
    ./sddm.nix
    ./xserver.nix
  ];
}
