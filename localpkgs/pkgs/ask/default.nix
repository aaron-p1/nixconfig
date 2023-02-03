{ stdenv, bash, jq, makeWrapper, lib }:
stdenv.mkDerivation {
  pname = "ask";
  version = "1.0.0";
  src = ./.;
  buildInputs = [ bash jq ];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp ask $out/bin
    wrapProgram $out/bin/ask \
      --prefix PATH : ${lib.makeBinPath [ bash jq ]}
  '';
}
