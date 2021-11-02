{
  description = "Local pkgs repo overlay";

  outputs = { self }: {
    overlay = final: prev: {
      local = rec {
        gotmux = prev.callPackage ./pkgs/gotmux {};
        nvlax = prev.callPackage ./pkgs/nvlax {};
        # patched with https://github.com/keylase/nvidia-patch
        nvidia_x11 = linuxPackages: prev.callPackage ./overrides/nvidia_x11-fbc {
          linuxPackages = linuxPackages;
          nvlax = nvlax;
        };
        latte-dock = prev.callPackage ./overrides/latte-dock {};
      };
    };
  };
}
