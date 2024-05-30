{ pkgs, ... }:
let
  ts = pkgs.vimPlugins.nvim-treesitter;

  bladeParserVersion = "0.10.0";
  bladeParserRepo = pkgs.fetchFromGitHub {
    owner = "EmranMR";
    repo = "tree-sitter-blade";
    rev = "v${bladeParserVersion}";
    sha256 = "sha256-sxnu2TvAvEnd2ftP+0hbhQGeiwWN1XY0RWHbDxQ3j88=";
  };

  bladeParser = pkgs.tree-sitter.buildGrammar {
    language = "blade";
    version = bladeParserVersion;
    src = bladeParserRepo;
    meta.homepage = "https://github.com/EmranMR/tree-sitter-blade";
  };

  nvim-treesitter = ts.withPlugins (_: ts.allGrammars ++ [ bladeParser ]);
in {
  name = "treesitter";
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter
    nvim-treesitter-textobjects
    vim-matchup
  ];
  extraFiles.queries = {
    nix."textobjects.scm" = ./queries/nix/textobjects.scm;
    php = {
      "textobjects.scm" = ./queries/php/textobjects.scm;
      "matchup.scm" = ./queries/php/matchup.scm;
    };
    blade = {
      "highlights.scm" = ./queries/blade/highlights.scm;
      "injections.scm" = bladeParserRepo + "/queries/injections.scm";
    };
  };
  config = # lua
    ''
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = false,
            include_surrounding_whitespace = true,
            keymaps = {
              -- custom
              aF = "@fnwithdoc.outer",
              ae = "@element.outer",
              ie = "@element.inner",
              ["i="] = "@assignexpression.inner",
              ["a="] = "@assignexpression.outer",
              ix = "@expression.inner",
              ax = "@expression.outer",
              -- builtin
              af = "@function.outer",
              ["if"] = "@function.inner",
              aa = "@parameter.outer",
              ia = "@parameter.inner",
              al = "@loop.outer",
              il = "@loop.inner",
              ao = "@conditional.outer",
              io = "@conditional.inner",
              ac = "@comment.outer",
            },
          },

          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
            },
          }
        },

        matchup = {
          enable = true,
          include_match_words = true
        },
      })

      require("match-up").setup({
        sync = true,
        matchparen = { offscreen = {} },
        transmute = { enabled = 1 },
      })
    '';
}
