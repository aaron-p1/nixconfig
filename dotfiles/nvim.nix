{ lib, fd, ripgrep, nodePackages, local, sumneko-lua-language-server, rnix-lsp
, nixfmt, shellcheck, shellharden, statix, stylua, nodejs, stdenv, findutils }:
let
  inherit (builtins) attrValues;
  inherit (lib) mapAttrsToList;

  dependencies = {
    # ---- telescope
    "fd" = fd;
    "rg" = ripgrep;

    # ---- lspconfig
    "intelephense" = nodePackages.intelephense;
    "jdtls" = local.jdt-language-server;
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

  nativeBuildInputs = [ findutils ];
  buildInputs = attrValues dependencies;

  replacements = mapAttrsToList (k: v: "s=@${k}@=${v}=g") dependencies;

  patchPhase = ''
    for rep in $replacements
    do
      find . -type f -print0 | xargs -0 sed -i "$rep"
    done
  '';

  installPhase = ''
    cp -r . $out
  '';

  meta = with lib; {
    description = "Dotfiles for neovim";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
