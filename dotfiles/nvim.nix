{ lib, xsel, python3, gnumake, unzip, gcc, fd, ripgrep, nodePackages, local
, sumneko-lua-language-server, rnix-lsp, nixfmt, shellcheck, shellharden, statix
, stylua, nodejs, stdenv, findutils, rsync }:
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
    statix
    nixfmt
    shellcheck
    shellharden
    stylua
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

  nativeBuildInputs = [ findutils local.yuescript rsync ];
  buildInputs = attrValues dependencies ++ addPath;

  replacements = mapAttrsToList (k: v: "s=@${k}@=${v}=g") dependencies;

  buildPhase = ''
    yue -t result .

    rsync --verbose --recursive --filter='- *.yue' --filter='- /result' ./ result

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
