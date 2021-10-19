{ stdenv, installShellFiles, lib }:
stdenv.mkDerivation {
  pname = "gotmux";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    mkdir -p $out/bin

    cp -v gotmux $out/bin
    cp -v etmux $out/bin
  '';

  postPhases = "postInstall";

  postInstall = ''
    installShellCompletion --bash --cmd gotmux completion
    installShellCompletion --zsh --cmd gotmux completion
  '';

  meta = with lib; {
    description = "Easy loading of tmuxp configs";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
