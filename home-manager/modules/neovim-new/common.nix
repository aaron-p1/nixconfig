{ pkgs, localVimPlugins, ... }: {
  name = "common";
  plugins = with pkgs.vimPlugins; [
    vim-repeat
    vim-abolish
    vim-unimpaired
    nvim-surround
    dial-nvim
    comment-nvim

    localVimPlugins.ts-node-action
    localVimPlugins.compare-remotes-nvim
    localVimPlugins.match-visual-nvim
    localVimPlugins.virt-notes-nvim
    localVimPlugins.handle-errors-nvim
  ];
  config = # lua
    ''
      local enabled_spell_langs = { "de", "en" }

      local function enable_spell()
        vim.ui.select(
          enabled_spell_langs,
          { prompt = "Select spelllang" }, function(choice)
            if choice ~= nil then
              vim.opt_local.spelllang = choice
              vim.opt_local.spellfile = Configs.base.spelldir .. "/" .. choice .. ".utf-8.add"
              vim.opt_local.spell = true
            end
          end)
      end

      vim.keymap.set("n", "[os", enable_spell, { desc = "Enable spell" })
      vim.keymap.set("n", "yos", function()
        if vim.o.spell then
          vim.opt_local.spell = false
        else
          enable_spell()
        end
      end, { desc = "Toggle spell" })

      require("nvim-surround").setup({
        highlight = { duration = 0 },
        move_cursor = false,
        indent_lines = false,
      })

      local da = require("dial.augend")
      local dm = require("dial.map")

      require("dial.config").augends:register_group({
        default = {
          da.integer.alias.decimal_int,
          da.integer.alias.hex,
          da.integer.alias.octal,
          da.integer.alias.binary,
          da.date.alias["%Y-%m-%d"],
          da.date.alias["%d.%m.%Y"],
          da.date.alias["%d.%m.%y"],
          da.date.alias["%H:%M:%S"],
          da.date.alias["%H:%M"],
          da.constant.alias.bool,
          da.semver.alias.semver,

          da.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
          da.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
          da.hexcolor.new({ case = "lower" })
        }
      })

      vim.keymap.set("n", "<C-a>", dm.inc_normal(), { desc = "Increment" })
      vim.keymap.set("n", "<C-x>", dm.dec_normal(), { desc = "Decrement" })
      vim.keymap.set("n", "g<C-a>", dm.inc_gnormal(), { desc = "Increment more per repeat" })
      vim.keymap.set("n", "g<C-x>", dm.dec_gnormal(), { desc = "Decrement more per repeat" })
      vim.keymap.set("v", "<C-a>", dm.inc_visual(), { desc = "Increment" })
      vim.keymap.set("v", "<C-x>", dm.dec_visual(), { desc = "Decrement" })
      vim.keymap.set("v", "g<C-a>", dm.inc_gvisual(), { desc = "Increment more per line" })
      vim.keymap.set("v", "g<C-x>", dm.dec_gvisual(), { desc = "Decrement more per line" })

      require("Comment").setup()

      vim.keymap.set("n", "<C-S-a>", require("ts-node-action").node_action, { desc = "Node action" })

      do
        local remotes_file_content = table.concat(
          vim.fn.readfile("${./secrets/static/comparable-remotes.json}")
        )
        local remotes_json = vim.json.decode(remotes_file_content)
        local remote_keys = { "all", unpack(Configs.profiles.list_applied) }

        local remotes_list = vim.tbl_map(function(profile)
          return remotes_json[profile] or {}
        end, remote_keys)

        local remotes = vim.tbl_extend("force", {}, {}, unpack(remotes_list))

        require("compare-remotes").setup({
          remotes = remotes,
          mapping = { key = "<Leader>cr" }
        })
      end

      require("match-visual").setup({ min_length = 2 })

      require("virt-notes").setup()

      local err_bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(err_bufnr, "ErrorLog")
      if err_bufnr ~= 0 then
        vim.keymap.set("n", "<Leader>Ex", function()
          vim.api.nvim_open_win(err_bufnr, true, {
            split = 'below',
            win = 0
          })
        end, { desc = "Horizontal" })
        vim.keymap.set("n", "<Leader>Ev", function()
          vim.api.nvim_open_win(err_bufnr, true, {
            split = 'right',
            win = 0
          })
        end, { desc = "Vertical" })

        local he = require("handle_errors")
        he.set_on_error(function(msg)
          local lines = vim.split(msg, "\n")
          lines[#lines + 1] = ""
          lines[#lines + 1] = "From: " .. os.date("%Y-%m-%d %H:%M:%S")
          lines[#lines + 1] = "---------------------------------------"
          lines[#lines + 1] = ""

          vim.api.nvim_buf_set_lines(err_bufnr, 1, 1, false, lines)
        end)
      end

      Configs.which_key.add({
        { "v",  group = "Virt notes" },
        { "vd", group = "Delete" },
        { "E",  group = "Open error buffer" },
      }, { "<Leader>" })
    '';
}
