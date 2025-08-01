{
  stdenv,
  bash,
  tmuxp,
  installShellFiles,
  makeWrapper,
  lib,
}:
stdenv.mkDerivation {
  pname = "gotmux";
  version = "1.1.0";

  src = ./.;

  buildInputs = [
    bash
    tmuxp
  ];
  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  patchPhase = ''
    substituteInPlace completions/gotmux.bash \
      --replace tmuxp ${tmuxp}/bin/tmuxp
    substituteInPlace completions/gotmux.zsh \
      --replace tmuxp ${tmuxp}/bin/tmuxp
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    install gotmux etmux ntmux $out/bin

    wrapProgram $out/bin/gotmux \
      --prefix PATH : ${lib.makeBinPath [ tmuxp ]}
    wrapProgram $out/bin/etmux \
      --prefix PATH : ${lib.makeBinPath [ tmuxp ]}

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd gotmux completions/gotmux.{bash,zsh}
    installShellCompletion --cmd etmux completions/gotmux.{bash,zsh}
  '';

  meta = with lib; {
    description = "Easy loading of tmuxp configs";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
