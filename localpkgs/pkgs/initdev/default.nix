{
  stdenv,
  python3,
  installShellFiles,
  lib,
}:
stdenv.mkDerivation {
  pname = "initdev";
  version = "1.0.0";

  src = ./.;

  buildInputs = [ python3 ];

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    install -m755 -D initdev $out/bin/initdev;
    mkdir -p $out/share
    cp -r envfiles $out/share/initdev-envfiles

    installShellCompletion completions/initdev.{bash,zsh}
  '';

  meta = {
    description = "Copy nix files for new dev environment";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
