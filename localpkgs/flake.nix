{
  description = "Local pkgs repo overlay";

  outputs = { self }: {
    overlay = final: prev: {
      local = {
        gotmux = prev.callPackage ./pkgs/gotmux {};
        # patched with https://github.com/keylase/nvidia-patch
        nvidia_x11 = linuxPackages: prev.callPackage ./overrides/nvidia_x11-fbc {
          linuxPackages = linuxPackages;
        };
      };
    };
  };
}
