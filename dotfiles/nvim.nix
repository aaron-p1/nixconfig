{ lib, xsel, python3, gnumake, unzip, gcc, fd, ripgrep, nodePackages, local
, sumneko-lua-language-server, rnix-lsp, nixfmt, shellcheck, shellharden
, editorconfig-checker, statix, stylua, fnlfmt, nodejs, stdenv, findutils
, fennel, parallel, rsync }:
let
  inherit (builtins) attrValues;
  inherit (lib) mapAttrsToList;

  addPath = [
    # core
    xsel
    # packer
    python3
    gnumake
    unzip
    gcc
    # telescope cmp-fuzzy-path
    fd
    # telescope
    ripgrep
    # copilot
    nodejs
    # null-ls
    editorconfig-checker
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

  dependencies = {
    # ---- dap
    "phpdebug" = local.vscode-php-debug;
  };
in stdenv.mkDerivation {
  pname = "dotfiles-nvim";
  version = "1.0.0";

  src = ./nvim;

  nativeBuildInputs = [ findutils fennel parallel rsync ];
  buildInputs = attrValues dependencies ++ addPath;

  replacements = mapAttrsToList (k: v: "s=@${k}@=${v}=g") dependencies;

  buildPhase = ''
    # fennel
    find . -name '*.fnl' \
      | parallel mkdir -p 'result/{//}' '&&' \
      fennel --globals vim --correlate -c '{}' '>' 'result/{.}.lua'

    rsync --verbose --recursive --filter='- *.fnl' \
      --filter='- /result' ./ result

    sed -i "s=@ADDPATH@=${lib.makeBinPath addPath}=g" result/init.lua

    for rep in $replacements
    do
      find result -type f -print0 | xargs -0 sed -i "$rep"
    done
  '';

  installPhase = ''
    cp -r result $out
  '';

  meta = with lib; {
    description = "Dotfiles for neovim";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
