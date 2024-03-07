{ buildNpmPackage, fetchFromGitHub, nodejs_16, pkg-config, libsecret }:
# https://nixos.org/manual/nixpkgs/stable/#javascript-tool-specific
buildNpmPackage {
  name = "vscode-php-debug";

  src = fetchFromGitHub {
    owner = "xdebug";
    repo = "vscode-php-debug";
    rev = "3025d1f01b5b7725e7c1c213d63f3de45f0534b3";
    hash = "sha256-ApIlakizqYorA7gJjqgeIXj8iJeXYYWybLvfLlozbW8=";
  };

  nodejs = nodejs_16;

  npmDepsHash = "sha256-w6yxEtWNw1Agtcor/sSspm/9h4vUOMm+nASCvr6LbBU=";
  makeCacheWritable = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libsecret ];

  installPhase = ''
    mkdir -p $out
    cp -r out node_modules $out
  '';
}
