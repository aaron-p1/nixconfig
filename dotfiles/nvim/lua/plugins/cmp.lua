local plugin = {}

function plugin.config()
	local cmp = require'cmp'
	cmp.setup {
		sources = {
			{
				name = 'nvim_lsp',
				max_item_count = 16
			},
			{ name = 'luasnip' },
			{ name = 'path' },
			{ name = 'calc' },
			{ name = 'cmp_tabnine' },
			{ name = 'buffer' },
		},
		snippet = {
			expand = function(args)
				require'luasnip'.lsp_expand(args.body)
			end
		},
		mapping = {
			['<C-Space>'] = cmp.mapping.complete(),
			['<C-y>'] = cmp.mapping.confirm({
					behavior = cmp.ConfirmBehavior.Replace,
					select = true
				}),
			['<C-e>'] = cmp.mapping({
					i = cmp.mapping.abort(),
					c = cmp.mapping.close(),
				}),
			['<C-u>'] = cmp.mapping.scroll_docs(-4),
			['<C-d>'] = cmp.mapping.scroll_docs(4),
			['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), {'i', 'c'}),
			['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), {'i', 'c'}),
			['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), {'c'}),
			['<Up>'] = cmp.config.disable,
			['<Right>'] = cmp.config.disable,
			['<Down>'] = cmp.config.disable,
			['<Left>'] = cmp.config.disable,
		},
		preselect = cmp.PreselectMode.Item;
		formatting = {
			format = function(entry, vim_item)
				local orig_menu = vim_item.menu
				-- set a name for each source
				vim_item.menu = ({
						buffer = '[B]',
						path = '[P]',
						calc = '[C]',
						luasnip = '[SNIP]',
						nvim_lsp = '[LSP]',
						cmp_tabnine = '[T9]',
						omni = '[OMNI]'
					})[entry.source.name]

				if orig_menu ~= nil then
					vim_item.menu = vim_item.menu .. ': ' .. orig_menu
				end

				return vim_item
			end,
		},
		experimental = {
			ghost_text = true,
		},
	}

	cmp.setup.cmdline('/', {
			sources = {
				{ name = 'buffer' }
			},
		})

	cmp.setup.cmdline(':', {
			sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				}),
		})

	vim.cmd[[
		autocmd FileType tex,plaintex lua require('cmp').setup.buffer {sources = {{name = 'omni'}, {name = 'luasnip'}, {name = 'path'}, {name = 'calc'}, {name = 'cmp_tabnine'}, {name = 'buffer'}}}
	]]
end

return plugin
