_: final: prev: {
  dotfiles = {
    nvim = prev.callPackage ./nvim.nix { };
    eww = prev.callPackage ./eww { };
  };
}
