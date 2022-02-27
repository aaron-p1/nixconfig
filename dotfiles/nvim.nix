{ lib, fd, ripgrep,

dart, elixir, elixir_ls, haskell-language-server, nodePackages, local
, sumneko-lua-language-server, rnix-lsp, texlab, texlive,

nixfmt, shellcheck, shellharden, statix, stylua, stdenv, findutils }:
let
  inherit (builtins) attrValues;
  inherit (lib) mapAttrsToList;

  dependencies = {
    # Telescope
    "fd" = fd;
    "rg" = ripgrep;

    # lspconfig
    "dart" = dart;
    "elixir" = elixir;
    "elixirls" = elixir_ls;
    "hls" = haskell-language-server;
    "intelephense" = nodePackages.intelephense;
    "jdtls" = local.jdt-language-server;
    "luals" = sumneko-lua-language-server;
    "rnix" = rnix-lsp;
    "texlab" = texlab;
    "texlive" = texlive.combined.scheme-medium;
    "vscodelsp" = nodePackages.vscode-langservers-extracted;
    "vls" = nodePackages.vls;
    "yamlls" = nodePackages.yaml-language-server;

    # null-ls
    "nixfmt" = nixfmt;
    "shellcheck" = shellcheck;
    "shellharden" = shellharden;
    "statix" = statix;
    "stylua" = stylua;
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
