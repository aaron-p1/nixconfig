{ inputs, ... }:
let inherit (inputs) jdt-ls;
in final: prev: {
  local = rec {
    gotmux = prev.callPackage ./pkgs/gotmux { };

    initdev = prev.callPackage ./pkgs/initdev { };

    # firefox native messaging hosts
    ff2mpv-native-client = prev.callPackage ./pkgs/ff2mpv-native-client { };

    # java language server
    inherit (jdt-ls.legacyPackages."${final.system}") jdt-language-server;

    # Nvidia
    nvlax = prev.callPackage ./pkgs/nvlax { };
    # patched with https://github.com/keylase/nvidia-patch
    nvidia_x11 = linuxPackages:
      prev.callPackage ./overrides/nvidia_x11-fbc {
        inherit linuxPackages nvlax;
      };
  };
}
