{ stdenv, fetchFromGitHub, cmake, pkg-config, lua }:
stdenv.mkDerivation rec {
  pname = "yuescript";
  version = "0.10.6";

  src = fetchFromGitHub {
    owner = "pigpigyyy";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-U1do22wQ87f/IImeXNKA61zr+HcKIA+e0q8aGEeYW2Q=";
  };

  patches = [ ./fixup-cmakelists.patch ];

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ lua ];
}
