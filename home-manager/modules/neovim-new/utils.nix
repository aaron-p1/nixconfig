_: {
  name = "utils";
  config = # lua
    ''
      local M = { ftdetect = {} }

      ---add ft detect by file name
      ---@param pattern string|string[]
      ---@param ft string
      function M.ftdetect.fname(pattern, ft)
        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          pattern = pattern,
          callback = function()
            vim.bo.filetype = ft
          end
        })
      end

      ---remove common indent of multi line string
      ---@param str string
      ---@return string
      function M.dedent(str)
        local lines = vim.split(str, "\n")
        local min_indent = math.huge

        for _, line in ipairs(lines) do
          local indent = string.match(line, "^%s+")

          if indent ~= nil and #indent < min_indent then
            min_indent = #indent
          end
        end

        for i, line in ipairs(lines) do
          lines[i] = string.sub(line, min_indent + 1)
        end

        return table.concat(lines, "\n")
      end

      ---get indent level of string
      ---@param str string
      ---@param indent string
      ---@return string
      local function get_indent_level(str, indent)
        local indent_level = 0

        while string.match(str, "^" .. indent) do
          indent_level = indent_level + 1
          str = string.sub(str, #indent + 1)
        end

        return indent_level
      end

      ---replace indent `old_indent` with tab char
      ---@param str string
      ---@param old_indent string
      ---@return string
      function M.indent_with_tab(str, old_indent)
        assert(old_indent ~= nil and #old_indent > 0, "old_indent must be non-empty string")

        local lines = vim.split(str, "\n")

        for i, line in ipairs(lines) do
          local indent_level = get_indent_level(line, old_indent)
          lines[i] = string.rep("\t", indent_level) .. string.sub(line, #old_indent * indent_level + 1)
        end

        return table.concat(lines, "\n")
      end

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
