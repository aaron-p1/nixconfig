{ inputs, ... }:
let inherit (inputs) jdt-ls;
in final: prev: {
  local = rec {
    nix-autobahn = prev.callPackage ./pkgs/nix-autobahn/default.nix { };

    gotmux = prev.callPackage ./pkgs/gotmux { inherit (prev.stable) tmuxp; };

    initdev = prev.callPackage ./pkgs/initdev { };

    vscode-php-debug = prev.callPackage ./pkgs/vscode-php-debug { };

    yuescript = prev.callPackage ./pkgs/yuescript { };

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
