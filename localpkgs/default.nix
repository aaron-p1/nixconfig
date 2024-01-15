{ inputs, ... }:
final: prev: {
  local = rec {
    create-project = prev.callPackage ./pkgs/create-project { };

    nix-autobahn = prev.callPackage ./pkgs/nix-autobahn/default.nix { };

    gotmux = prev.callPackage ./pkgs/gotmux { inherit (prev.stable) tmuxp; };
    ask = prev.callPackage ./pkgs/ask { };

    initdev = prev.callPackage ./pkgs/initdev { };

    vscode-php-debug = prev.callPackage ./pkgs/vscode-php-debug { };

    # firefox native messaging hosts
    ff2mpv-native-client = prev.callPackage ./pkgs/ff2mpv-native-client { };

    # Nvidia
    nvlax = prev.callPackage ./pkgs/nvlax { };
    # patched with https://github.com/keylase/nvidia-patch
    nvidia-patched = nvidia_x11:
      prev.callPackage ./overrides/nvidia-patched { inherit nvidia_x11 nvlax; };
  };
}
