{ mkYarnPackage, fetchFromGitHub }:
# yarn import
# yarn2nix > yarn.nix
# yarm.lock versions not found because it is defining name@*
mkYarnPackage {
  name = "vscode-php-debug";
  src = fetchFromGitHub {
    owner = "xdebug";
    repo = "vscode-php-debug";
    rev = "84d7444ed80f7f7830b03bdfdb0fe746ffbdde0f";
    sha256 = "sha256-/D6+Sd+MJG9C2aQyIW2OWjUC02r2svG7kUNJAqCxRAg=";
  };
  yarnLock = ./yarn.lock;
  yarnNix = ./yarn.nix;
  buildPhase = "yarn --offline run build";
  distPhase = "true";
}
