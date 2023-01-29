{ lib, xsel, python3, gnumake, unzip, gcc, tree-sitter, fd, ripgrep
, nodePackages, local, sumneko-lua-language-server, rnix-lsp, nixfmt, shellcheck
, shellharden, editorconfig-checker, statix, stylua, fnlfmt, nodejs-16_x, stdenv
, findutils, fennel }:
let
  inherit (builtins) attrValues;
  inherit (lib) concatStringsSep mapAttrsToList;

  addPath = [
    # core
    xsel
    # packer
    python3
    gnumake
    unzip
    gcc
    tree-sitter
    # telescope cmp-fuzzy-path
    fd
    # telescope
    ripgrep
    # copilot
    nodejs-16_x
    # null-ls
    editorconfig-checker
    nodePackages.prettier
    statix
    nixfmt
    shellcheck
    shellharden
    stylua
    fnlfmt
    # lspconfig
    nodePackages.intelephense
    sumneko-lua-language-server
    rnix-lsp
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
  ];
in stdenv.mkDerivation {
  pname = "dotfiles-nvim";
  version = "1.0.0";

  src = ./nvim;

  nativeBuildInputs = [ findutils fennel ];
  buildInputs = addPath;
  makeFlags = [ "PREFIX=$(out)" ];
  enableParallelBuilding = true;

  # additional env vars
  addPath = lib.makeBinPath addPath;

  postPatch = ''
    # replace env vars in place
    find . -type f | while read -r file; do
      substituteAllInPlace "$file"
    done
  '';

  meta = with lib; {
    description = "Dotfiles for neovim";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
