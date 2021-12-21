{
  description = "Local pkgs repo overlay";

  inputs = {
    jdt-ls.url =
      "github:nixos/nixpkgs?rev=3ae6abea23628f16a1c60ce9f9ec36deb0b5a59e";
  };

  outputs = { self, jdt-ls }: {
    overlay = final: prev: {
      local = rec {
        gotmux = prev.callPackage ./pkgs/gotmux { };

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
    };
  };
}
