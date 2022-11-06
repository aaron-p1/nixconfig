{ symlinkJoin, nvidia_x11, nvlax, ... }:
symlinkJoin {
  name = "nvidia-patched-${nvidia_x11.version}";
  paths = [ nvidia_x11 ];
  buildInputs = [ nvlax ];
  postBuild = ''
    encodePath=("$out/lib/libnvidia-encode.so."???*)
    fbcPath=("$out/lib/libnvidia-fbc.so."???*)

    echo "$encodePath"
    echo "$fbcPath"

    [[ "$encodePath" =~ ^[^\ ]*a-encode\.so\.[0-9]{3}[^/]*$ ]] || exit 1
    [[ "$fbcPath" =~ ^[^\ ]*a-fbc\.so\.[0-9]{3}[^/]*$ ]] || exit 1

    echo Paths valid

    encode="$(readlink -f "$encodePath")"
    fbc="$(readlink -f "$fbcPath")"

    rm "$encodePath" "$fbcPath"

    echo Patching

    nvlax_encode -i "$encode" -o "$encodePath"
    nvlax_fbc -i "$fbc" -o "$fbcPath"

    chmod +x "$encodePath" "$fbcPath"
  '';
  passthru = {
    inherit (nvidia_x11) useProfiles persistenced settings bin lib32;
  };
}
