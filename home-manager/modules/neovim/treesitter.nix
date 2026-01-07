{ pkgs, ... }:
{
  within.neovim.configDomains.treesitter = {
    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      vim-matchup
    ];
    extraFiles.queries = {
      lua."injections.scm" = ./queries/lua/injections.scm;
      nix."textobjects.scm" = ./queries/nix/textobjects.scm;
      php = {
        "injections.scm" = ./queries/php/injections.scm;
        "textobjects.scm" = ./queries/php/textobjects.scm;
        "matchup.scm" = ./queries/php/matchup.scm;
      };
    };
    config = # lua
      ''
        local big_file_size = 1024 * 1024
        local is_big_file_buffer = {}

        local function calc_big_file(bufnr)
          local line_count = vim.api.nvim_buf_line_count(bufnr)
          local buffer_size = vim.api.nvim_buf_get_offset(bufnr, line_count)
          return buffer_size > big_file_size or buffer_size / line_count > vim.o.synmaxcol
        end

        local function is_big_file(bufnr)
          if is_big_file_buffer[bufnr] ~= nil then
            return is_big_file_buffer[bufnr]
          end

          local big_file = calc_big_file(bufnr)
          is_big_file_buffer[bufnr] = big_file
          return big_file
        end

        vim.api.nvim_create_autocmd('FileType', {
          pattern = '*',
          callback = function(ev)
            if is_big_file(ev.buf) then
              return
            end

            local ok = pcall(vim.treesitter.start, ev.buf)

            if ok then
              vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
        })

        require("nvim-treesitter-textobjects").setup({
          select = {
            lookahead = false,
            include_surrounding_whitespace = true,
            selection_modes = {
              ["@parameter.outer"] = "v",
              ["@function.inner"] = "v",
              ["@function.outer"] = "v",
            }
          },

          move = {
            set_jumps = true,
          },
        })

        local textobject_mappings = {
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
        }

        local to_select = require("nvim-treesitter-textobjects.select")
        for key, query in pairs(textobject_mappings) do
          vim.keymap.set(
            {"o", "x"},
            key,
            function() to_select.select_textobject(query, "textobjects") end,
            { noremap = true, silent = true }
          )
        end

        local to_move = require("nvim-treesitter-textobjects.move")
        local next_start = to_move.goto_next_start
        local next_end = to_move.goto_next_end
        local prev_start = to_move.goto_previous_start
        local prev_end = to_move.goto_previous_end

        local textobject_move_mappings = {
          ["]m"] = {next_start, "@function.outer"},
          ["]M"] = {next_end, "@function.outer"},
          ["[m"] = {prev_start, "@function.outer"},
          ["[M"] = {prev_end, "@function.outer"},
        }

        for key, mapping in pairs(textobject_move_mappings) do
          local func = mapping[1]
          local query = mapping[2]
          vim.keymap.set(
            {"n", "o", "x"},
            key,
            function() func(query, "textobjects") end,
            { noremap = true, silent = true }
          )
        end

        require("match-up").setup({
          sync = true,
          matchparen = { offscreen = {} },
          transmute = { enabled = 1 },
          treesitter = {
            enabled = true,
            disabled = {},
            include_match_words = true,
            disable_virtual_text = false,
            enable_quotes = true,
            stopline = 500,
          }
        })
      '';
  };
}
