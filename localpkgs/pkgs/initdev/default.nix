{ stdenv, python3, installShellFiles, lib }:
stdenv.mkDerivation {
  pname = "initdev";
  version = "1.0.0";

  src = ./.;

  buildInputs = [ (python3.withPackages (p: with p; [ ])) ];

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    install -m755 -D initdev $out/bin/initdev;
    mkdir -p $out/share
    cp -r envfiles $out/share/initdev-envfiles

    installShellCompletion completions/initdev.{bash,zsh}
  '';

  meta = with lib; {
    description = "Copy nix files for new dev environment";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
