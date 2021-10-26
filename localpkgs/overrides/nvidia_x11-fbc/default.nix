{ callPackage, linuxPackages, ... }:
let
  nvidiaPatchList = callPackage ({ stdenvNoCC, fetchFromGitHub, ... }:
  stdenvNoCC.mkDerivation {
    pname = "nvidia-patch-nvfbc";
    version = "2021-10-21";

    src = fetchFromGitHub {
      owner = "keylase";
      repo = "nvidia-patch";
      rev = "a38cf8fa4e310d5aaa78e545cc4d51db164448b5";
      sha256 = "sha256-eSonkDkHOVhEHV28lkcqfeGCmQ3amiICq/g4OoilNqY=";
    };

    awkExtractPatches = ''
      BEGIN {
          FS = "[\"']";
          p = 0;
          f = 0;
          lines[""]="";
      }
      /^)$/ && p {p=0}
      /^)$/ && f {exit}

      p && $2 {lines[$2]=$2 "\t" $4}
      f && $2 {print lines[$2] "\t" $4}

      /declare.*patch_list/ {p=1}
      /declare.*object_list/ {f=1}
    '';

    buildPhase = ''
      awk "$awkExtractPatches" patch-fbc.sh > patchlist_fbc.txt
      awk "$awkExtractPatches" patch.sh > patchlist_enc.txt
    '';

    installPhase = ''
      mkdir $out
      cp patchlist_{fbc,enc}.txt $out
    '';
  }) {};
in
  linuxPackages.nvidiaPackages.stable.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ nvidiaPatchList ];
    postFixup = ''
      fbcpatch="$(< ${nvidiaPatchList}/patchlist_fbc.txt grep -F '${oldAttrs.version}' | cut -f2,3)"
      fbcsub="$(<<< $fbcpatch cut -f 1)"
      fbcfile="$(<<< $fbcpatch cut -f 2)"

      [ -n "$fbcsub" ] && [ -n "$fbcfile" ] || {
        echo "Driver version (${oldAttrs.version}) not found in fbc patches" 1>&2
        exit 1
      }

      encpatch="$(< ${nvidiaPatchList}/patchlist_enc.txt grep -F '${oldAttrs.version}' | cut -f2,3)"
      encsub="$(<<< $encpatch cut -f 1)"
      encfile="$(<<< $encpatch cut -f 2)"

      [ -n "$encsub" ] && [ -n "$encfile" ] || {
        echo "Driver version (${oldAttrs.version}) not found in enc patches" 1>&2
        exit 1
      }

      sed -i "$fbcsub" $out/lib/"$fbcfile"{,.1}
      sed -i "$encsub" $out/lib/"$encfile"{,.1}

    '';
  })
