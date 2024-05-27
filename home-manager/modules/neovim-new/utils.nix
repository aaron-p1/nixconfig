_: {
  name = "utils";
  config = # lua
    ''
      local M = {}

      ---open new terminal buffer with split command
      ---@param cmd string command to run in terminal
      ---@param opts table options for split command
      function M.new_term(cmd, opts)
        local name = "term://" .. cmd
        local split_opts = vim.tbl_deep_extend("keep", { name }, opts)

        vim.cmd.split(split_opts)
      end

      ---open terminal buffer with horizontal split
      ---@param cmd string
      function M.open_term_hor(cmd)
        M.new_term(cmd, {})
      end

      ---open terminal buffer with vertical split
      ---@param cmd string
      function M.open_term_ver(cmd)
        M.new_term(cmd, { mods = { vertical = true } })
      end

      ---open terminal buffer with tab split
      ---@param cmd string
      function M.open_term_tab(cmd)
        local tabnr = vim.api.nvim_tabpage_get_number(0)
        M.new_term(cmd, { mods = { tab = tabnr } })
      end

      ---add 3 keymaps for opening terminal with different split kinds
      ---@param key string keymap prefix
      ---@param cmd string command to run in terminal
      ---@param opts table keymap options
      function M.add_term_keymaps(key, cmd, opts)
        opts = opts or {}

        vim.keymap.set("n", key .. "x", function() M.open_term_hor(cmd) end,
          vim.tbl_extend("force", opts, { desc = "Horizontal" }))
        vim.keymap.set("n", key .. "v", function() M.open_term_ver(cmd) end,
          vim.tbl_extend("force", opts, { desc = "Vertical" }))
        vim.keymap.set("n", key .. "t", function() M.open_term_tab(cmd) end,
          vim.tbl_extend("force", opts, { desc = "Tab" }))
      end

      ---get 0-indexed range of operator motion
      ---@param motion_type string
      ---@return table
      function M.get_operator_range(motion_type)
        local charwise = motion_type == "char"
        local start_mark_row, start_mark_col = unpack(vim.api.nvim_buf_get_mark(0, "["))
        local end_mark_row, end_mark_col = unpack(vim.api.nvim_buf_get_mark(0, "]"))
        local start_row = start_mark_row - 1
        local end_row = end_mark_row - 1

        if charwise then
          return { start_row, start_mark_col, end_row, end_mark_col + 1 }
        else
          local end_line_length = #vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]

          return { start_row, 0, end_row, end_line_length }
        end
      end

      return M
    '';
}
