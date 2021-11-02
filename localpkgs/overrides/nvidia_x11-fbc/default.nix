{ callPackage, linuxPackages, nvlax, ... }:
linuxPackages.nvidiaPackages.stable.overrideAttrs (oldAttrs: {
  nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ nvlax ];
  postFixup = ''
    nvlax_encode -i $out/lib/libnvidia-encode.so -o $out/lib/libnvidia-encode.so
    nvlax_encode -i $(readlink $out/lib/libnvidia-encode.so.1) -o $(readlink $out/lib/libnvidia-encode.so.1)

    nvlax_fbc -i $out/lib/libnvidia-fbc.so -o $out/lib/libnvidia-fbc.so
    nvlax_fbc -i $(readlink $out/lib/libnvidia-fbc.so.1) -o $(readlink $out/lib/libnvidia-fbc.so.1)
  '';
})
