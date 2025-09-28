{ pkgs, ... }:
{
  within.neovim.configDomains.ui = {
    plugins = with pkgs.vimPlugins; [
      gruvbox-nvim
      nvim-colorizer-lua
      indent-blankline-nvim

      nvim-web-devicons
      lualine-nvim

      # input
      dressing-nvim
      # messages
      fidget-nvim
    ];
    config = # lua
      ''
        local gb = require("gruvbox")

        gb.setup({
          terminal_colors = false,
          invert_selection = true,
          overrides = {
            ["@tag.blade"] = { link = "Keyword" },

            SpellBad = { link = "GruvboxYellowUnderline" },

            DiffDelete = { bg = "#9a2a2a", fg = "NONE", reverse = false },
            DiffAdd = { bg = "#284028", fg = "NONE", reverse = false },
            DiffChange = { bg = "#284848", fg = "NONE", reverse = false },
            DiffText = { bg = "#575728", fg = "NONE", reverse = false },

            NormalFloat = { bg = gb.palette.dark1 },

            VisualMatch = { bg = "#5c534c" },

            TelescopeMatching = { link = "GruvboxRedBold" },
            TelescopeSelection = { fg = "NONE", bg = gb.palette.dark2, bold = false },

            FloatBorder = { link = "TelescopeBorder" },
            FloatTitle = { link = "TelescopeTitle" },

            LuasnipChoiceActive = { link = "GruvboxOrange" },
            LuasnipChoiceVisited = { link = "GruvboxGreen" },
            LuasnipChoiceUnvisited = { link = "GruvboxRed" },
            LuasnipInsertActive = { link = "GruvboxBlue" },
            LuasnipInsertVisited = { link = "GruvboxGreen" },
            LuasnipInsertUnvisited = { link = "GruvboxRed" },

            CmpItemAbbrMatch = { link = "GruvboxRedBold" },
            CmpItemAbbrMatchFuzzy = { link = "GruvboxYellow" },

            NvimTreeWindowPicker = { fg = gb.palette.dark0 },

            CopilotSuggestion = { fg = "#00FF88", italic = true },

            VirtNote = { fg = gb.palette.bright_blue, bg = gb.palette.dark2 },
          }
        })

        vim.cmd.colorscheme("gruvbox")

        vim.g.terminal_color_0 = "#181818"
        vim.g.terminal_color_1 = "#AC4242"
        vim.g.terminal_color_2 = "#90A959"
        vim.g.terminal_color_3 = "#F4BF75"
        vim.g.terminal_color_4 = "#6A9FB5"
        vim.g.terminal_color_5 = "#AA759F"
        vim.g.terminal_color_6 = "#75B5AA"
        vim.g.terminal_color_7 = "#D8D8D8"
        vim.g.terminal_color_8 = "#6B6B6B"
        vim.g.terminal_color_9 = "#C55555"
        vim.g.terminal_color_10 = "#AAC474"
        vim.g.terminal_color_11 = "#FECA88"
        vim.g.terminal_color_12 = "#82B8C8"
        vim.g.terminal_color_13 = "#C28CB8"
        vim.g.terminal_color_14 = "#93D3C3"
        vim.g.terminal_color_15 = "#F8F8F8"

        local term_ns = vim.api.nvim_create_namespace("TerminalColors")
        vim.api.nvim_set_hl(term_ns, "Normal", { fg = vim.g.terminal_color_7, bg = vim.g.terminal_color_0 })

        local group = vim.api.nvim_create_augroup("TerminalColors", {})

        vim.api.nvim_create_autocmd({ "TermOpen", "TermEnter", "TermClose" }, {
          group = group,
          callback = function()
            local wins = vim.api.nvim_list_wins()

            for _, win in ipairs(wins) do
              local win_bufnr = vim.api.nvim_win_get_buf(win)
              local buf_name = vim.api.nvim_buf_get_name(win_bufnr)

              if string.match(buf_name, "^term://") then
                vim.api.nvim_win_set_hl_ns(win, term_ns)
              else
                vim.api.nvim_win_set_hl_ns(win, 0)
              end
            end
          end
        })

        require("colorizer").setup({
          filetypes = { "*" },
          user_default_options = {
            RRGGBBAA = true,
            AARRGGBB = true,
            rgb_fn = true,
            hsl_fn = true,
            css = true,
            css_fn = true,
            tailwind = true,
            sass = { enable = false },
          }
        })

        require("ibl").setup({
          exclude = { filetypes = { "help", "packer" } },
          scope = { show_end = false },
        })

        require("lualine").setup({
          options = { theme = "onedark", globalstatus = false },
          extensions = { "fugitive" },
          sections = {
            lualine_a = { "mode" },
            lualine_b = { "filename" },
            lualine_c = { "diagnostics" },
            lualine_x = { "diff", "branch" },
            lualine_y = { "filetype" },
            lualine_z = { "progress", "location" },
          },
          inactive_sections = {
            lualine_a = { "filename" },
            lualine_b = { "diagnostics" },
            lualine_c = {},
            lualine_x = { "diff", "branch" },
            lualine_y = { "filetype" },
            lualine_z = { "progress", "location" },
          },
          tabline = {
            lualine_a = {
              {
                "tabs",
                tab_max_length = 32,
                max_length = function()
                  return vim.o.columns - 4
                end,
                mode = 2,
                path = 1,
                symbols = { modified = "+" }
              }
            }
          }
        })

        local d_select_float_min_width = 80
        local d_select_float_width_factor = 0.8
        local d_select_float_min_height = 15
        local d_select_float_height_factor = 0.9

        local function get_select_float_width(_, max_cols)
          return math.min(
            max_cols,
            math.max(d_select_float_min_width, math.floor(d_select_float_width_factor * max_cols))
          )
        end

        local function get_select_float_height(_, _, max_rows)
          return math.min(
            max_rows,
            math.max(d_select_float_min_height, math.floor(d_select_float_height_factor * max_rows))
          )
        end

        require("dressing").setup({
          input = {
            insert_only = false,
            start_in_insert = true,
            win_options = { winblend = 0 },
            min_width = { 70, 0.2 },
            get_config = function(c) return c.center and { relative = "editor" } or nil end
          },
          select = {
            backend = { "telescope", "builtin" },
            telescope = Configs.telescope.themes.get_dropdown({
              layout_config = {
                width = get_select_float_width,
                height = get_select_float_height
              }
            }),
          }
        })

        require("fidget").setup({
          progress = {
            display = {
              done_ttl = 1,
            }
          },
          notification = {
            override_vim_notify = true,
            window = {
              align = "top",
              winblend = 0,
              max_width = 200
            },
            view = {
              stack_upwards = false
            }
          }
        })
      '';
  };
}
