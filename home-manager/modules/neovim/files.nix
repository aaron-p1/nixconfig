{ pkgs, ... }: {
  within.neovim.configDomains.files = {
    plugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      nvim-tree-lua
      oil-nvim
    ];
    packages = with pkgs; [ fd ];
    config = # lua
      ''
        local t = require("nvim-tree")
        local tv = require("nvim-tree.view")
        local ta = require("nvim-tree.api")
        local tl = require("nvim-tree.lib")
        local tc = require("nvim-tree.core")

        local open_file = require("nvim-tree.actions.node.open-file").fn

        ---get path and position from selected entry in telescope
        ---@param cwd string?
        ---@return string
        ---@return integer[]
        local function get_telescope_path(cwd)
          local entry = Configs.telescope.state.get_selected_entry()
          local file_path = (cwd and cwd .. "/" or "") .. entry.filename

          return file_path, { entry.lnum, entry.col }
        end

        ---open file selected in telescope
        ---@param cwd string?
        ---@param action string
        ---@param prompt_bufnr integer
        local function open_telescope_selected(cwd, action, prompt_bufnr)
          local file_path, pos = get_telescope_path(cwd)

          Configs.telescope.actions.close(prompt_bufnr)
          open_file(action, file_path)

          if pos then
            vim.cmd.normal({ pos[1] .. "G" .. pos[2] .. "|zz", bang = true })
          end
        end

        ---live grep in directory of selected node
        local function live_grep_in_dir()
          local node = ta.tree.get_node_under_cursor()
          local abs_path = node.type == "directory" and node.absolute_path
              or node.parent and node.parent.absolute_path

          if abs_path then
            Configs.telescope.builtin.live_grep({
              cwd = abs_path,
              attach_mappings = function(_, map)
                map({ "n", "i" }, "<CR>", function(prompt_bufnr)
                  open_telescope_selected(abs_path, "edit", prompt_bufnr)
                end)
                map({ "n", "i" }, "<C-x>", function(prompt_bufnr)
                  open_telescope_selected(abs_path, "split", prompt_bufnr)
                end)
                map({ "n", "i" }, "<C-v>", function(prompt_bufnr)
                  open_telescope_selected(abs_path, "vsplit", prompt_bufnr)
                end)

                return true
              end
            })
          end
        end

        ---find directory and navigate to it
        local function find_directory()
          local explorer_filters = tc.get_explorer().opts.filters;

          Configs.telescope.builtin.find_files({
            find_command = {
              "fd",
              "--type=directory",
              "--strip-cwd-prefix",
              "--exclude=.git",
              explorer_filters.dotfiles and "--hidden" or nil,
              explorer_filters.git_ignored and "--no-ignore" or nil
            },
            attach_mappings = function(_, map)
              map({ "n", "i" }, "<CR>", function(prompt_bufnr)
                Configs.telescope.actions.close(prompt_bufnr)
                ta.tree.find_file(get_telescope_path())
                vim.cmd.normal({ "zz", bang = true })

                local node = ta.tree.get_node_under_cursor()
                if not node.open then
                  tl.expand_or_collapse(node)
                end
              end)
              map({ "n", "i" }, "<C-x>", function(prompt_bufnr)
                open_telescope_selected(nil, "split", prompt_bufnr)
              end)
              map({ "n", "i" }, "<C-v>", function(prompt_bufnr)
                open_telescope_selected(nil, "vsplit", prompt_bufnr)
              end)

              return true
            end
          })
        end

        local function always_open(action)
          local node = ta.tree.get_node_under_cursor()

          open_file(action, node.absolute_path)
        end

        t.setup({
          disable_netrw = false,
          hijack_netrw = false,
          git = { enable = false },
          on_attach = function(bufnr)
            ta.config.mappings.default_on_attach(bufnr)

            local function setmap(key, cb, desc)
              vim.keymap.set("n", key, cb, { desc = "nvim-tree: " .. desc, buffer = bufnr })
            end

            setmap("O", function() always_open("edit") end, "Edit file and dir")
            setmap("<C-x>", function() always_open("split") end, "Split file and dir")
            setmap("<C-v>", function() always_open("vsplit") end, "Vsplit file and dir")
            setmap("<C-t>", function() always_open("tabnew") end, "Tabnew file and dir")
            setmap("<Leader>ff", find_directory, "Find directory")
            setmap("<Leader>fr", live_grep_in_dir, "Live grep in dir")
          end
        })

        vim.keymap.set("n", "<Leader>bb", ta.tree.toggle, { desc = "Toggle" })
        vim.keymap.set("n", "<Leader>bf", function() ta.tree.open({ find_file = true }) end, { desc = "Find file" })
        vim.keymap.set("n", "<Leader>b<", function() tv.resize("-20") end, { desc = "Resize -20" })
        vim.keymap.set("n", "<Leader>b>", function() tv.resize("+20") end, { desc = "Resize +20" })

        local f_group = vim.api.nvim_create_augroup("FugitiveNvimTree", {})
        vim.api.nvim_create_autocmd("FileType", {
          group = f_group,
          pattern = "fugitive",
          callback = function(ev)
            vim.keymap.set("n", "<Leader>bf", function()
              local line = vim.api.nvim_get_current_line()
              local fname = string.match(line, "^. (.+)$")

              if fname then
                ta.tree.open()
                ta.tree.find_file(fname)
              end
            end, { desc = "Find file", buffer = ev.buf })
          end
        })

        Configs.which_key.add({ { "<Leader>b", group = "Nvim Tree" } })

        local oil = require("oil")

        local function select_tab()
          oil.select({ horizontal = true })
          local keys = vim.api.nvim_replace_termcodes("<C-w>T", true, false, true)
          vim.api.nvim_feedkeys(keys, "n", true)
        end

        oil.setup({
          default_file_explorer = false,
          columns = { "icon", "permissions", "size" },
          view_options = { show_hidden = true },
          keymaps = { ["<C-t>"] = select_tab },
          silence_scp_warning = true
        })
      '';
  };
}
