{ lib, gawk, bash, hyprland, jq, socat, stdenvNoCC, makeWrapper }:
let
  scriptDependencies = [ gawk bash hyprland jq socat ];
  scriptPath = lib.makeBinPath scriptDependencies;

in stdenvNoCC.mkDerivation {
  pname = "dotfiles-eww-scripts";
  version = "1.0.0";

  src = ./scripts;

  buildInputs = scriptDependencies;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    install * $out/bin

    for script in $out/bin/*; do
      wrapProgram $script --prefix PATH : ${scriptPath}
    done
  '';
}
