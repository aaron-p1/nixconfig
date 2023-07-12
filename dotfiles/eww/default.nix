{ callPackage, stdenvNoCC, findutils }:
let scriptPkg = callPackage ./scripts.nix { };
in stdenvNoCC.mkDerivation {
  pname = "dotfiles-eww";
  version = "1.0.0";

  src = ./config;

  buildInputs = [ scriptPkg ];
  nativeBuildInputs = [ findutils ];

  scripts = "${scriptPkg}/bin";

  patchPhase = ''
    # replace env vars in place
    find . -type f | while read -r file; do
      substituteAllInPlace "$file"
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out
  '';
}
