{ pkgs, ... }: {
  name = "base";
  packages = with pkgs; [ wl-clipboard ];
  config = # lua
    ''
      local spelldir = vim.fn.stdpath('data') .. '/spell'

      vim.fn.mkdir(spelldir, 'p')

      local opts = {
        -- common
        termguicolors = true,
        background = 'dark',
        synmaxcol = 300,
        updatetime = 300,
        timeoutlen = 500,
        shelltemp = false,
        mouse = "",

        -- menu
        showcmd = true,
        ruler = true,
        number = true,
        relativenumber = true,
        cursorline = true,
        colorcolumn = '+1',
        scrolljump = -10,
        scrolloff = 8,

        -- search
        hlsearch = true,
        incsearch = true,
        ignorecase = true,
        smartcase = true,

        -- buffer
        linebreak = true,
        showbreak = '↪',
        list = true,
        listchars = { tab = '──', trail = '❯', nbsp = '˰' },
        conceallevel = 2,
        concealcursor = 'n',
        undofile = true,
        diffopt = { 'internal', 'filler', 'closeoff', 'vertical', 'linematch:102' },
        completeopt = { 'menuone', 'noselect' },
        omnifunc = 'syntaxcomplete#Complete',
        expandtab = true,
        tabstop = 2,
        shiftwidth = 2,

        foldmethod = 'indent',
        foldlevelstart = 99,

        spell = true,
        spelloptions = { 'camel', 'noplainbuffer' },
        spelllang = { 'en', 'de', 'cjk' },
        spellfile = spelldir .. '/custom.utf-8.add',

        -- window handling
        splitbelow = true,
        splitright = true,

        -- closing
        hidden = true,
        confirm = true,
      }

      for k, v in pairs(opts) do
        vim.opt[k] = v
      end

      vim.cmd.language('en_US.utf8')

      -- TODO temp
      vim.opt.runtimepath:remove("/home/aaron/.config/nvim")

      vim.keymap.set("n", "<PageUp>", "<nop>")
      vim.keymap.set("n", "<PageDown>", "<nop>")
      -- alt + Esc for leaving terminal
      vim.keymap.set("t", "<A-Esc>", "<C-\\><C-n>")
      -- diff maps
      vim.keymap.set("n", "<Leader>du", ":diffupdate<CR>", { silent = true })
      vim.keymap.set("n", "<Leader>dt", ":diffthis<CR>", { silent = true })

      vim.keymap.set("n", "<Leader>n", "<Cmd>nohlsearch<CR>", { silent = true })

      -- tab maps
      local function close_tab()
        local count = vim.v.count == 0 and 1 or vim.v.count
        local go_prev = vim.api.nvim_tabpage_get_number(0) + count <= #vim.api.nvim_list_tabpages()

        pcall(function()
          for _ = 1, count do
            vim.cmd.tabclose()
          end
        end)

        if go_prev and vim.api.nvim_tabpage_get_number(0) > 1 then
          vim.cmd.tabprevious()
        end
      end

      vim.keymap.set("n", "<C-w><C-t>", "<Cmd>tab split<CR>", { silent = true, desc = "Open in new tab" })
      vim.keymap.set("n", "<Leader>tc", close_tab, { desc = "Tab close" })
      vim.keymap.set("n", "<Leader>to", "<Cmd>tabonly<CR>", { silent = true })

      -- terminal
      Configs.utils.add_term_keymaps("<Leader>ctt", vim.o.shell)
      Configs.utils.add_term_keymaps("<Leader>cts", "~//" .. vim.o.shell)

      -- replace text object
      function Replace_selection(motion_type)
        local start_row, start_col, end_row, end_col = unpack(Configs.utils.get_operator_range(motion_type))
        ---@type string[]
        local register_content = vim.fn.getreg('0', 1, true)

        vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, register_content)
      end

      vim.keymap.set("n", "gp", "<Cmd>set operatorfunc=v:lua.Replace_selection<CR>g@", { silent = true })

      -- TODO which-key

      local term_augroup = vim.api.nvim_create_augroup("Terminal", {})

      ---send data to terminal
      ---@param input string
      local function send_to_terminal(input)
        local job_id = vim.b.terminal_job_id
        if job_id then
          vim.api.nvim_chan_send(job_id, input)
        end
      end

      vim.api.nvim_create_autocmd("TermOpen", {
        group = term_augroup,
        callback = function(ev)
          local buf = ev.buf

          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
          vim.opt_local.cursorline = false
          vim.opt_local.spell = false
          vim.opt_local.scrolloff = 0

          vim.api.nvim_buf_call(buf, function() vim.cmd.normal("G") end)

          vim.keymap.set("n", "cd", function() send_to_terminal("\004") end, { buffer = buf, desc = "Send <C-d>" })
          vim.keymap.set("n", "cc", function() send_to_terminal("\003") end, { buffer = buf, desc = "Send <C-c>" })
        end
      })

      ---"term://dir//pid:cmd" -> "term://dir//cmd"
      ---@param title string
      ---@return string
      local function remove_pid_from_term_title(title)
        title = vim.fn.substitute(title, "term://.\\{-}//\\zs\\d*:", "", "")
        title = title:gsub("\\", "\\\\\\")
        return title
      end

      ---replace buffer in windows
      ---@param old_buf integer
      ---@param new_buf integer
      local function replace_buffer_in_wins(old_buf, new_buf)
        local wins = vim.fn.win_findbuf(old_buf)
        for _, win in ipairs(wins) do
          vim.api.nvim_win_set_buf(win, new_buf)
        end
      end

      vim.api.nvim_create_autocmd("TermClose", {
        group = term_augroup,
        callback = function(ev)
          local buf = ev.buf
          local new_cmd = remove_pid_from_term_title(ev.file)

          vim.keymap.set("n", "r", function()
            vim.cmd.edit(new_cmd)

            local new_buf = vim.api.nvim_get_current_buf()
            replace_buffer_in_wins(buf, new_buf)
            vim.api.nvim_buf_delete(buf, { force = true })
            vim.cmd.normal("G")
          end, { buffer = buf })

          vim.keymap.set("n", "q", function()
            vim.api.nvim_buf_delete(buf, { force = true })
          end, { buffer = buf })
        end
      })

      -- highlight on yank
      local yank_augroup = vim.api.nvim_create_augroup("YankHighlight", {})

      vim.api.nvim_create_autocmd("TextYankPost", {
        group = yank_augroup,
        callback = function() vim.highlight.on_yank({ timeout = 300 }) end
      })

      -- delete hidden scp files
      local scp_augroup = vim.api.nvim_create_augroup("HiddenScp", {})

      vim.api.nvim_create_autocmd("BufRead", {
        group = scp_augroup,
        pattern = "scp://*",
        callback = function() vim.bo.bufhidden = "delete" end
      })
      return { spelldir = spelldir }
    '';
}
