{
  description = "Local pkgs repo overlay";

  outputs = { self }: {
    overlay = final: prev: {
      local = {
        gotmux = prev.callPackage ./pkgs/gotmux/default.nix {};
      };
    };
  };
}
