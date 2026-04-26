-- this has to be done to be able to override arrow_function.
-- If target_nodes is non empty table (default), it ignores fallback.
-- If I override it with empty table below, it will be ignored and not changed.
require("treesj.settings").settings.langs.php.arrow_function.target_nodes = {}

local function anon_to_arrow(node)
  local params = node:field('parameters')[1]
  local body = node:field('body')[1]
  if not params or not body then return end

  if body:named_child_count() ~= 1 then return end

  local body_stmt = body:named_child(0)
  if not body_stmt then return end

  local body_expr = body_stmt
  if body_stmt:type() == 'return_statement' then
    body_expr = body_stmt:named_child(0)
  end

  if not body_expr then return end

  local bufnr          = 0

  local step           = vim.bo[bufnr].expandtab
      and string.rep(' ', vim.bo[bufnr].shiftwidth)
      or '\t'

  local params_txt     = vim.treesitter.get_node_text(params, bufnr)
  local expr_txt       = vim.treesitter.get_node_text(body_expr, bufnr)
      :gsub('\n' .. step, "\n")

  local sr, sc, er, ec = node:range()
  local replacement    = vim.split('fn' .. params_txt .. ' => ' .. expr_txt, '\n')

  vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, replacement)
end

local function arrow_to_anon(node)
  local params = node:field('parameters')[1]
  local body = node:field('body')[1]
  if not params or not body then return end

  local bufnr                 = 0
  local params_txt            = vim.treesitter.get_node_text(params, bufnr)
  local body_txt              = vim.treesitter.get_node_text(body, bufnr)

  local sr, sc, er, ec        = node:range()
  local line                  = vim.api.nvim_buf_get_lines(bufnr, sr, sr + 1, false)[1] or ""
  local indent                = line:match('^[ \t]*') or ""
  local step                  = vim.bo[bufnr].expandtab
      and string.rep(' ', vim.bo[bufnr].shiftwidth)
      or '\t'

  local params_lines          = vim.split(params_txt, "\n")
  params_lines[1]             = "function" .. params_lines[1]
  params_lines[#params_lines] = params_lines[#params_lines] .. " {"

  local body_lines            = vim.split(body_txt, "\n")
  body_lines[1]               = indent .. "return " .. body_lines[1]
  body_lines                  = vim.tbl_map(function(l) return step .. l end, body_lines)
  body_lines[#body_lines]     = body_lines[#body_lines] .. ";"

  local lines                 = vim
      .iter({
        params_lines,
        body_lines,
        indent .. '}',
      })
      :flatten()
      :totable()
  vim.api.nvim_buf_set_text(bufnr, sr, sc, er, ec, lines)
end

return {
  anonymous_function = { both = { fallback = anon_to_arrow } },
  arrow_function = { both = { fallback = arrow_to_anon } }
}
