local kset = vim.keymap.set

local set_options = require('helper').set_options
local wk_register = require('plugins.which-key').register

local log_count = 50

set_options(vim.opt_local, { foldmethod = 'syntax' })

local maps = {
  p = 'pull',
  f = 'fetch',
  P = 'push',
  l = 'log -' .. log_count,
  L = 'log -' .. (log_count * 2),
}

for key, command in pairs(maps) do
  kset('n', '<Leader>g' .. key, '<Cmd>Git ' .. command .. '<CR>', { buffer = true })
end

kset('n', 'cO<Space>', '<Space>:Git switch ', { buffer = true })

if vim.b.fugitive_type == 'index' then
  kset('n', 'R', '<Cmd>Git<CR>', { buffer = true })
end

wk_register({
  buffer = 0,
  prefix = '<Leader>',
  map = {
    g = {
      name = 'Git',
      p = 'Pull',
      f = 'Fetch',
      P = 'Push',
      l = 'Log ' .. log_count,
      L = 'Log ' .. (log_count * 2),
    },
  },
})

wk_register({
  buffer = 0,
  prefix = 'c',
  map = {
    O = {
      name = 'Switch branch',
    },
  },
})
