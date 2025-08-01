{ pkgs, nvimUtil, ... }:
{
  within.neovim.configDomains.common = {
    overlay = nvimUtil.pluginOverlay (
      { prev, pvP, ... }:
      let
        inherit (prev) fetchFromGitHub;
        inherit (prev.vimUtils) buildVimPlugin;
      in
      {
        handle-errors-nvim = buildVimPlugin {
          pname = "handle_errors.nvim";
          version = "2025-03-31";
          src = fetchFromGitHub {
            owner = "aaron-p1";
            repo = "handle_errors.nvim";
            rev = "6acac18ef99ee2e4bfde908c11c84a5fa2b35af8";
            sha256 = "sha256-cqAJkIljJWgq5bZIWGsjEKG6MK/paNhACndDk036h0U=";
          };
          buildInputs = [ prev.luajit ];
          buildPhase = "make";
          meta.homepage = "https://github.com/aaron-p1/handle_errors.nvim";
          meta.platforms = [ "x86_64-linux" ];
        };
        match-visual-nvim = buildVimPlugin {
          pname = "match-visual.nvim";
          version = "2024-04-29";
          src = fetchFromGitHub {
            owner = "aaron-p1";
            repo = "match-visual.nvim";
            rev = "98540e79c151126187907278ff5bc61823edcebc";
            sha256 = "sha256-wYBueqOcIfqJOFjdSAUHe8725i9dKmwqTxaNWW3gmg4=";
          };
          meta.homepage = "https://github.com/aaron-p1/match-visual.nvim";
        };
        virt-notes-nvim = buildVimPlugin {
          pname = "virt-notes.nvim";
          version = "2023-09-10";
          src = fetchFromGitHub {
            owner = "aaron-p1";
            repo = "virt-notes.nvim";
            rev = "1c43e82cc996e3df570b9d08a305bc7e5135ab0e";
            sha256 = "sha256-I6oygOgFX3Bzy4rJ1MQUebxy+VGLBXJfXPPFsQZzubA=";
          };
          meta.homepage = "https://github.com/aaron-p1/virt-notes.nvim";
        };
        compare-remotes-nvim = buildVimPlugin {
          pname = "compare-remotes.nvim";
          version = "2023-02-15";
          src = fetchFromGitHub {
            owner = "aaron-p1";
            repo = "compare-remotes.nvim";
            rev = "501f6dba3c916204a3bf586d7b4b789a64157aad";
            sha256 = "sha256-mEk8JgOjUp/3FDBu3DgumHqa3+kuT7SjzQLEmEvc42Y=";
          };
          meta.homepage = "https://github.com/aaron-p1/compare-remotes.nvim";
        };
        ts-node-action = buildVimPlugin {
          pname = "ts-node-action";
          version = "2024-05-30";
          src = fetchFromGitHub {
            owner = "CKolkey";
            repo = "ts-node-action";
            rev = "6d3b60754fd87963d70eadaa2f77873b447eac26";
            sha256 = "sha256-kOXH3r+V+DAxoATSnZepEAekrkO1TezKSkONuQ3Kzu4=";
          };
          meta.homepage = "https://github.com/CKolkey/ts-node-action";
          dependencies = [ pvP.nvim-treesitter ];
        };
      }
    );
    plugins = with pkgs.vimPlugins; [
      vim-repeat
      vim-abolish
      vim-unimpaired
      nvim-surround
      dial-nvim
      comment-nvim

      ts-node-action
      compare-remotes-nvim
      match-visual-nvim
      virt-notes-nvim
      handle-errors-nvim
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

          local profile_remotes = vim.tbl_extend("force", {}, {}, unpack(remotes_list))

          -- Format: 'Name1:path1,Name2:path2'
          local env_string = vim.env.NVIM_COMPARABLE_REMOTES

          local env_remotes = vim.iter(vim.gsplit(env_string or "", ","))
            :filter(function(remote)
              return remote:match("^[^:]+:.+$")
            end)
            :map(function(remote)
              local parts = vim.split(remote, ":")
              return { name = parts[1], path = parts[2] }
            end)
            :fold({}, function(acc, remote)
              acc[remote.name] = remote.path
              return acc
            end)

          local remotes = vim.tbl_extend("force", profile_remotes, env_remotes)

          require("compare-remotes").setup({
            remotes = remotes,
            mapping = { key = "<Leader>cr" },
            project_file_schemes = { "oil" },
            scheme_replacements = { dir = { scp = "oil-ssh" } },
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
            lines[#lines + 1] = "At: " .. os.date("%Y-%m-%d %H:%M:%S")
            lines[#lines + 1] = "---------------------------------------"
            lines[#lines + 1] = ""

            vim.schedule(function()
              pcall(vim.api.nvim_buf_set_lines, err_bufnr, 1, 1, false, lines)
            end)
          end)
        end

        Configs.which_key.add({
          { "v",  group = "Virt notes" },
          { "vd", group = "Delete" },
          { "E",  group = "Open error buffer" },
        }, { "<Leader>" })
      '';
  };
}
