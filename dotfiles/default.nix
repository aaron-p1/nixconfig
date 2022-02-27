_: final: prev: {
  dotfiles = {
    nvim = prev.callPackage ./nvim.nix { };
  };
}
