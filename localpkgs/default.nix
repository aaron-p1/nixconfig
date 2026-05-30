{ inputs, ... }:
final: prev: {
  local = {
    initdev = prev.callPackage ./pkgs/initdev { };

    # firefox native messaging hosts
    ff2mpv-native-client = prev.callPackage ./pkgs/ff2mpv-native-client { };
  };
}
