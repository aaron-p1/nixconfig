{ stdenv, fetchFromGitHub, cmake, zydis, pkg-config, lief, ... }:
let
  zycore = stdenv.mkDerivation rec {
    pname = "zycore";
    version = "0.9.0";

    src = fetchFromGitHub {
      owner = "zyantific";
      repo = "zycore-c";
      rev = "636bb29945c94ffe4cedb5b6cc797e42c98de3af";
      sha256 = "sha256-Rtg5nXj4Cplr1xr3lz8lexzmkvQL9v75a6Blc0f+To0=";
    };

    nativeBuildInputs = [ cmake ];
  };
  fixedZydis = zydis.overrideAttrs (old: {
    src = fetchFromGitHub {
      owner = "zyantific";
      repo = "zydis";
      rev = "55dd08c210722aed81b38132f5fd4a04ec1943b5";
      sha256 = "sha256-ljUOgHsaQizKv4k/tj1+ZX+quPm122ikxNrqUg743qA=";
      fetchSubmodules = true;
    };
  });
in stdenv.mkDerivation rec {
  pname = "nvlax";
  version = "unstable-2021-11-01";

  srcs = [
    (fetchFromGitHub {
      owner = "illnyang";
      repo = pname;
      rev = "b3699ad40c4dfbb9d46c53325d63ae8bf4a94d7f";
      sha256 = "sha256-xNZnMa4SFUFwnJAOruez9JxnCC91htqzR5HOqD4RZtc=";
      name = pname;
    })
    (fetchFromGitHub {
      owner = "gpakosz";
      repo = "PPK_ASSERT";
      rev = "833b8b7ea49aea540a49f07ad08bf0bae1faac32";
      sha256 = "sha256-gGhqhdPMweFjhGPMGza5MwEOo5cJKrb5YrskjCvWX3w=";
      name = "ppk";
    })
  ];

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ fixedZydis zycore lief ];

  sourceRoot = pname;

  postUnpack = ''
    mkdir ${pname}/build
    cp -rp -- ppk ${pname}/build/ppk
  '';

  # Remove CPM from cmakelists
  patches = [
    ./fixup-cmakelists.patch
    ./fixup-pointer-access.patch
  ];
}
