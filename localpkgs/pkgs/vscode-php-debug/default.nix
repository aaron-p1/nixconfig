{ stdenv, fetchzip }:
stdenv.mkDerivation rec {
  pname = "vscode-php-debug";
  version = "1.24.3";

  src = fetchzip rec {
    url =
      "https://github.com/xdebug/${pname}/releases/download/v${version}/php-debug-${version}.vsix";
    sha256 = "sha256-FUoCYrumyoDEMcm8xX/c0F7ziCL+A2pSuWTKPSH+kU0=";
    extension = "zip";

    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out

    cp -r extension/out/* $out
  '';
}
