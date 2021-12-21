{ neovim-nightly, tree-sitter, rustPlatform, fetchFromGitHub, ... }:
neovim-nightly.override {
  tree-sitter = tree-sitter.override {
    rustPlatform = rustPlatform // {
      buildRustPackage = args:
        rustPlatform.buildRustPackage (args // {
          src = fetchFromGitHub {
            owner = "tree-sitter";
            repo = "tree-sitter";
            rev = "v0.20.0";
            sha256 = "sha256-z/otxUXkFGWUSMxku6Q1UklVz8/L0QR67NIRwreOLEM=";
            fetchSubmodules = true;
          };

          cargoSha256 = "sha256-sTkbsSUYwYpIDjFkS5dhEp+xb38CrIjk6o3p6vskwXQ=";
        });
    };
  };
}

