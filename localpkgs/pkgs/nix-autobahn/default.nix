{ lib, stdenv, fetchFromGitHub, makeWrapper, findutils, fzf, nix-index, nix-ld }:
stdenv.mkDerivation rec {
  pname = "nix-autobahn";
  version = "2022-03-22";

  src = fetchFromGitHub {
    owner = "Lassulus";
    repo = pname;
    rev = "31e2378025819cfaa9ea62eea858b6535488aa39";
    sha256 = "sha256-AFtEXmDNCn87HIuhos0OyptGEmIHx+Fj60KpjY7UFE0=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ findutils fzf nix-index nix-ld ];

  installPhase = ''
    mkdir -p $out/bin

    cp nix-autobahn $out/bin
    cp nix-autobahn-fhs-shell $out/bin
    cp nix-autobahn-find-libs $out/bin
    cp nix-autobahn-ld $out/bin
    cp nix-autobahn-ld-shell $out/bin

    wrapProgram $out/bin/nix-autobahn-find-libs \
      --prefix PATH : ${lib.makeBinPath buildInputs}
  '';
}
