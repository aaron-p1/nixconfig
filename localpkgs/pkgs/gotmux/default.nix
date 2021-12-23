{ stdenv, tmuxp, installShellFiles, lib }:
stdenv.mkDerivation {
  pname = "gotmux";
  version = "1.0.0";

  src = ./.;

  buildInputs = [ tmuxp ];

  nativeBuildInputs = [ installShellFiles ];

  patchPhase = ''
    patchShebangs gotmux
    patchShebangs completions/gotmux.bash

    substituteInPlace gotmux --replace tmuxp "${tmuxp}/bin/tmuxp"
    substituteInPlace completions/gotmux.bash --replace tmuxp "${tmuxp}/bin/tmuxp"
    substituteInPlace completions/gotmux.zsh --replace tmuxp "${tmuxp}/bin/tmuxp"
  '';

  installPhase = ''
    mkdir -p $out/bin

    cp -v gotmux $out/bin/gotmux

    chmod +x $out/bin/gotmux

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion completions/gotmux.{bash,zsh}
  '';

  meta = with lib; {
    description = "Easy loading of tmuxp configs";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
