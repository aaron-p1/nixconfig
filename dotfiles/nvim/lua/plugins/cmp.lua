local plugin = {}

function plugin.config()
	local cmp = require'cmp'
	cmp.setup {
		sources = {
			{ name = 'luasnip' },
			{
				name = 'nvim_lsp',
				max_item_count = 16
			},
			{ name = 'cmp_tabnine' },
			{ name = 'path' },
			{ name = 'calc' },
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
		},
		preselect = cmp.PreselectMode.Item;
		formatting = {
			format = function(entry, vim_item)
				-- set a name for each source
				vim_item.menu = ({
						buffer = '[B]',
						path = '[P]',
						calc = '[C]',
						luasnip = '[SNIP]',
						nvim_lsp = '[LSP]',
						cmp_tabnine = '[T9]',
					})[entry.source.name]
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
end

return plugin
