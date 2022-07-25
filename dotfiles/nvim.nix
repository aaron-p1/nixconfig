{ lib, fd, ripgrep, nodePackages, local, sumneko-lua-language-server, rnix-lsp
, nixfmt, shellcheck, shellharden, statix, stylua, nodejs, stdenv, findutils
, rsync }:
let
  inherit (builtins) attrValues;
  inherit (lib) mapAttrsToList;

  addPath = [
    # telescope cmp-fuzzy-path
    fd
    # telescope
    ripgrep
  ];

  dependencies = {
    # ---- lspconfig
    "intelephense" = nodePackages.intelephense;
    "luals" = sumneko-lua-language-server;
    "rnix" = rnix-lsp;
    "vscodelsp" = nodePackages.vscode-langservers-extracted;
    "yamlls" = nodePackages.yaml-language-server;

    # ---- null-ls
    # nix
    "nixfmt" = nixfmt;
    "statix" = statix;
    # shell
    "shellcheck" = shellcheck;
    "shellharden" = shellharden;
    # lua
    "stylua" = stylua;

    # ---- dap
    "phpdebug" = local.vscode-php-debug;
    "nodejs" = nodejs;
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
