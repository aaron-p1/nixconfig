{ pkgs, ... }: {
  name = "telescope";
  plugins = with pkgs.vimPlugins; [
    telescope-nvim
    telescope-fzf-native-nvim
    telescope-symbols-nvim
  ];
  packages = [ pkgs.fd pkgs.ripgrep ];
  config = # lua
    ''
      local tl = require("telescope")

      tl.setup({ defaults = { preview = { filesize_limit = 1 } } })

      tl.load_extension("fzf")

      local tb = require("telescope.builtin")

      vim.keymap.set("n", "<C-S-T>", tb.resume, { desc = "Resume latest search" })

      -- Files
      vim.keymap.set("n", "<Leader>fa", function()
        tb.find_files({
          find_command = {
            "fd",
            "--type=file",
            "--size=-1M",
            "--hidden",
            "--strip-cwd-prefix",
            "--no-ignore",
          }
        })
      end, { desc = "All files" })
      vim.keymap.set("n", "<Leader>ff", function()
        tb.find_files({
          find_command = {
            "fd",
            "--type=file",
            "--size=-1M",
            "--hidden",
            "--strip-cwd-prefix",
            "--exclude=.git",
          }
        })
      end, { desc = "Files" })
      vim.keymap.set("n", "<Leader>fe", function()
        tb.git_files({ git_command = { "git", "diff", "--name-only" } })
      end, { desc = "Git changed files" })

      -- Search (needs ripgrep)
      vim.keymap.set("n", "<Leader>fr", tb.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<Leader>ft", function()
        tb.grep_string({ additional_args = function() return { "--hidden" } end })
      end, { desc = "Grep string" })

      -- vim
      vim.keymap.set("n", "<Leader>fb", tb.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<Leader>fm", tb.marks, { desc = "Marks" })
      vim.keymap.set("n", "<Leader>fcr", tb.current_buffer_fuzzy_find, { desc = "Fuzzy find" })
      vim.keymap.set("n", "<Leader>fy", tb.filetypes, { desc = "Set filetype" })
      vim.keymap.set("n", "<Leader>fh", tb.help_tags, { desc = "Help tags" })

      -- lsp
      vim.keymap.set("n", "<Leader>fls", tb.lsp_document_symbols, { desc = "Document symbols" })

      -- git
      vim.keymap.set("n", "<Leader>fgc", tb.git_commits, { desc = "Commits" })
      vim.keymap.set("n", "<Leader>fgb", tb.git_bcommits, { desc = "BCommits" })
      vim.keymap.set("n", "<Leader>fgt", tb.git_stash, { desc = "Stash" })

      vim.keymap.set("n", "<Leader>fs", tb.symbols, { desc = "Symbols" })

      -- extensions
      vim.keymap.set("n", "<Leader>fv", function()
        tl.extensions.virt_notes.virt_notes()
      end, { desc = "Virt notes" })

      Configs.which_key.register({
        prefix = "<Leader>",
        map = {
          f = {
            name = "Telescope",
            c = { name = "Current buffer" },
            l = { name = "LSP" },
            g = { name = "Git" },
          }
        }
      })

      return {
        builtin = tb,
        themes = require("telescope.themes"),
        actions = require("telescope.actions"),
        state = require("telescope.actions.state"),
      }
    '';
}
