{ prev, final }:
prev.lief.overrideAttrs (old: rec {
  version = "0.12.2";

  src = final.fetchFromGitHub {
    owner = "lief-project";
    repo = "LIEF";
    rev = version;
    sha256 = "sha256-5n3AWzSTImLY8v/mc1mwiNb4/opFZOTXSJwizbUMYvU=";
  };
})
