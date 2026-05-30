_: {
  _class = "nixos";

  imports = [
    ./dms-niri.nix
    ./plasma.nix
    ./xserver.nix
  ];
}
